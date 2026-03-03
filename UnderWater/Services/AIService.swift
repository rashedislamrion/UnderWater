import Foundation
import Combine

// MARK: - AI Service

/// High-level service between the UI and `MLXModelManager`.
///
/// Responsibilities:
/// - Building well-structured, DeepSeek-Coder-friendly prompts.
/// - Forwarding the `AsyncStream<String>` token stream to the UI.
/// - Providing graceful fallback when the model is not loaded.
class AIService: ObservableObject {

    // MARK: Singleton
    static let shared = AIService()

    // MARK: Published state (mirrored from MLXModelManager)
    @Published var isModelLoaded: Bool = false
    @Published var isProcessing: Bool = false
    @Published var modelStatus: String = "Checking for model…"

    // MARK: Private
    private let modelManager = MLXModelManager.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init
    private init() {
        modelManager.$isModelLoaded
            .receive(on: DispatchQueue.main)
            .assign(to: &$isModelLoaded)

        modelManager.$statusMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$modelStatus)
    }

    // MARK: - Public API

    /// Triggers model loading via `MLXModelManager`.
    func loadModel() async {
        do {
            try await modelManager.loadModel()
        } catch {
            print("❌ [AIService] Failed to load model: \(error.localizedDescription)")
        }
    }

    /// Re-scans known disk locations for model files without triggering a full load.
    func refreshModelSearch() {
        Task { @MainActor in
            modelManager.checkForModel()
        }
    }

    /// Main entry point called by the chat UI.
    ///
    /// Returns an `AsyncStream<String>` that yields tokens one by one so the
    /// ChatPanelView can update the bubble in real time.
    ///
    /// - Parameters:
    ///   - code: Current file content (used as context).
    ///   - language: Programming language name, e.g. "swift".
    ///   - question: The user's natural-language question.
    func analyzeCode(
        code: String,
        language: String,
        question: String
    ) -> AsyncStream<String> {
        guard isModelLoaded else {
            // Return a one-shot stream with the "not loaded" message.
            let msg = notLoadedMessage()
            return AsyncStream { continuation in
                continuation.yield(msg)
                continuation.finish()
            }
        }

        Task { @MainActor in self.isProcessing = true }

        let prompt = buildPrompt(code: code, language: language, question: question)

        // Wrap the model stream so we can clear isProcessing when it finishes.
        let upstream = modelManager.generate(prompt: prompt, maxTokens: 768)

        return AsyncStream { continuation in
            Task {
                for await token in upstream {
                    continuation.yield(token)
                }
                continuation.finish()

                await MainActor.run { self.isProcessing = false }
            }
        }
    }

    // MARK: - Prompt Engineering

    private func buildPrompt(code: String, language: String, question: String) -> String {
        // Trim file content to ~2 000 chars to stay comfortably inside the
        // DeepSeek-Coder-V2-Lite 4K context window after accounting for
        // the system tokens and the generated answer.
        let context = String(code.prefix(2_000))

        // DeepSeek-Coder chat template.
        // See: https://huggingface.co/deepseek-ai/deepseek-coder-v2-lite-instruct
        return """
        <|begin_of_text|><|User|>You are an expert \(language.uppercased()) programming assistant. \
        Be concise, accurate, and use Markdown formatting in your answer.

        The user is viewing this \(language) file:
        ```\(language)
        \(context)
        ```

        User question: \(question)<|Assistant|>
        """
    }

    // MARK: - Fallback message

    private func notLoadedMessage() -> String {
        """
        **AI Model Not Loaded**

        \(modelManager.statusMessage)

        **To enable offline AI inference:**
        1. Add the Swift packages in Xcode (File → Add Package Dependencies):
           - `https://github.com/ml-explore/mlx-swift` (targets: MLX, MLXNN, MLXRandom)
           - `https://github.com/ml-explore/mlx-swift-lm` (targets: MLXLLM, MLXLMCommon)
        2. Enable **Increased Memory Limit** in Target → Signing & Capabilities
        3. Ensure the model folder is at:
           `~/Library/Application Support/UnderWater/Models/deepseek-coder-v2-lite`
        4. Tap **Load AI Model** in the panel above
        """
    }
}
