import Foundation
import Combine

// ---------------------------------------------------------------------------
// MLX IMPORTS — guarded so the file compiles even before the Swift packages
// are added. Once you add:
//   • https://github.com/ml-explore/mlx-swift       (targets: MLX, MLXNN, MLXRandom)
//   • https://github.com/ml-explore/mlx-swift-lm    (targets: MLXLLM, MLXLMCommon)
// …the canImport guard will resolve to true and real inference will activate.
// ---------------------------------------------------------------------------
#if canImport(MLXLMCommon) && canImport(MLXLLM)
import MLX
import MLXNN
import MLXRandom
import MLXLMCommon
import MLXLLM
#endif

// MARK: - Errors

enum ModelError: LocalizedError {
    case modelNotFound
    case modelNotLoaded
    case packagesNotLinked
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "Model not found. Place the deepseek-coder-v2-lite folder at ~/Library/Application Support/UnderWater/Models/"
        case .modelNotLoaded:
            return "Model is not loaded. Tap 'Load AI Model' first."
        case .packagesNotLinked:
            return "MLX Swift packages not yet linked. Add mlx-swift and mlx-swift-lm in Xcode → File → Add Package Dependencies."
        case .generationFailed(let detail):
            return "Generation failed: \(detail)"
        }
    }
}

// MARK: - MLXModelManager

/// Manages the lifecycle of the offline MLX language model.
///
/// **Setup required (one-time in Xcode):**
/// 1. File → Add Package Dependencies → https://github.com/ml-explore/mlx-swift  (branch: main)
///    Link targets: MLX, MLXNN, MLXRandom, MLXOptimizers
/// 2. File → Add Package Dependencies → https://github.com/ml-explore/mlx-swift-lm  (branch: main)
///    Link targets: MLXLLM, MLXLMCommon
/// 3. Target → Signing & Capabilities → + Increased Memory Limit
@MainActor
final class MLXModelManager: ObservableObject {

    // MARK: Singleton
    static let shared = MLXModelManager()

    // MARK: Published state
    @Published var isModelLoaded: Bool = false
    @Published var isLoading: Bool = false
    @Published var loadingProgress: Double = 0.0
    @Published var statusMessage: String = "Checking for model…"
    @Published var modelPath: URL? = nil
    @Published var errorMessage: String? = nil

    // MARK: Private — model container
    // Typed as AnyObject so file compiles without packages linked.
    // When MLXLMCommon is imported this holds a real `ModelContainer`.
    private var container: AnyObject? = nil

    // MARK: Init
    private init() {
        checkForModel()
    }

    // MARK: - Model Discovery

    func checkForModel() {
        errorMessage = nil

        // 1. ~/Library/Application Support/UnderWater/Models/deepseek-coder-v2-lite
        if let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first {
            let candidate = appSupport
                .appendingPathComponent("UnderWater/Models/deepseek-coder-v2-lite")
            if FileManager.default.fileExists(atPath: candidate.path) {
                modelPath = candidate
                statusMessage = "Model found. Tap 'Load AI Model' to start."
                print("✅ [MLXModelManager] Model found at: \(candidate.path)")
                return
            }
        }

        // 2. App bundle Resources/Models/deepseek-coder-v2-lite
        if let bundlePath = Bundle.main.resourceURL?
            .appendingPathComponent("Models/deepseek-coder-v2-lite"),
           FileManager.default.fileExists(atPath: bundlePath.path) {
            modelPath = bundlePath
            statusMessage = "Model found in app bundle. Tap 'Load AI Model' to start."
            print("✅ [MLXModelManager] Model found in bundle at: \(bundlePath.path)")
            return
        }

        modelPath = nil
        statusMessage = "Model not found. See README for setup instructions."
        print("⚠️ [MLXModelManager] Model not found in any expected location.")
    }

    // MARK: - Model Loading

    func loadModel() async throws {
        guard let path = modelPath else {
            errorMessage = ModelError.modelNotFound.localizedDescription
            throw ModelError.modelNotFound
        }

        isLoading = true
        isModelLoaded = false
        loadingProgress = 0.0
        errorMessage = nil

        defer { isLoading = false }

        #if canImport(MLXLMCommon) && canImport(MLXLLM)
        do {
            statusMessage = "Initialising MLX model from disk…"
            loadingProgress = 0.05

            // Build a local-URL configuration. The ModelConfiguration(url:)
            // initialiser skips any HuggingFace download and reads directly
            // from the supplied filesystem path.
            let configuration = ModelConfiguration(url: path)

            statusMessage = "Loading tokenizer…"
            loadingProgress = 0.15

            // LLMModelFactory resolves the correct model architecture from
            // config.json, loads weights from *.safetensors, and builds the
            // tokenizer — all in one call.
            let loaded = try await LLMModelFactory.shared.loadContainer(
                configuration: configuration
            ) { [weak self] progress in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    // progress.fractionCompleted is 0.0 → 1.0
                    self.loadingProgress = 0.15 + (progress.fractionCompleted * 0.80)
                    self.statusMessage = "Loading model weights… \(Int(self.loadingProgress * 100))%"
                }
            }

            container = loaded
            loadingProgress = 1.0
            isModelLoaded = true
            statusMessage = "Model ready — offline inference active."
            print("✅ [MLXModelManager] Model loaded from \(path.lastPathComponent)")

        } catch {
            loadingProgress = 0.0
            isModelLoaded = false
            errorMessage = error.localizedDescription
            statusMessage = "Failed to load model."
            print("❌ [MLXModelManager] Load error: \(error)")
            throw ModelError.generationFailed(error.localizedDescription)
        }

        #else
        // Packages not yet linked — give a clear instruction to the developer.
        loadingProgress = 0.0
        isModelLoaded = false
        let msg = ModelError.packagesNotLinked.localizedDescription ?? ""
        errorMessage = msg
        statusMessage = "MLX packages missing — see console."
        print("⚠️ [MLXModelManager] \(msg)")
        throw ModelError.packagesNotLinked
        #endif
    }

    // MARK: - Streaming Inference

    /// Returns an `AsyncStream<String>` that yields decoded text fragments
    /// token-by-token as the model generates them.
    ///
    /// - Parameters:
    ///   - prompt: The fully-formatted prompt string.
    ///   - maxTokens: Hard cap on generated tokens (default 768).
    func generate(prompt: String, maxTokens: Int = 768) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                #if canImport(MLXLMCommon) && canImport(MLXLLM)
                guard isModelLoaded, let modelContainer = container as? ModelContainer else {
                    continuation.yield("[Error: model not loaded]")
                    continuation.finish()
                    return
                }

                do {
                    let parameters = GenerateParameters(temperature: 0.7, topP: 0.9)

                    // Run inference on the ModelContainer's actor context.
                    // `perform` serialises access to the model — safe from any caller.
                    _ = try await modelContainer.perform { context in
                        // Prepare input: wraps the raw prompt into the model's
                        // expected format (adds any special tokens / chat template).
                        let userInput = UserInput(prompt: prompt)
                        let lmInput = try context.processor.prepare(input: userInput)

                        // NaiveStreamingDetokenizer buffers partial BPE tokens
                        // and emits only complete, printable text fragments.
                        var detokenizer = NaiveStreamingDetokenizer(
                            tokenizer: context.tokenizer
                        )

                        return try MLXLMCommon.generate(
                            input: lmInput,
                            parameters: parameters,
                            context: context
                        ) { tokens in
                            if let last = tokens.last {
                                detokenizer.append(token: last)
                            }
                            // Flush any newly completed text fragments.
                            if let fragment = detokenizer.next() {
                                continuation.yield(fragment)
                            }
                            return tokens.count >= maxTokens ? .stop : .more
                        }
                    }
                } catch {
                    continuation.yield("\n[Generation error: \(error.localizedDescription)]")
                    print("❌ [MLXModelManager] Generation error: \(error)")
                }

                continuation.finish()

                #else
                continuation.yield("[MLX packages not linked — add mlx-swift and mlx-swift-lm in Xcode]")
                continuation.finish()
                #endif
            }
        }
    }

    // MARK: - Unload

    /// Releases the model from memory.
    func unloadModel() {
        container = nil
        isModelLoaded = false
        loadingProgress = 0.0
        statusMessage = "Model unloaded."
        print("🗑️ [MLXModelManager] Model unloaded from memory.")
    }
}
