import SwiftUI
import Combine

// MARK: - Chat Message Model

struct ChatMessage: Identifiable {
    let id = UUID()
    var content: String
    let isUser: Bool
    let timestamp = Date()
    var isStreaming: Bool = false
}

// MARK: - ChatPanelView

struct ChatPanelView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var aiService = AIService.shared

    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isWaitingForResponse = false

    var body: some View {
        VStack(spacing: 0) {
            headerView

            Divider()

            if !aiService.isModelLoaded {
                modelStatusBanner
                Divider()
            }

            messagesView

            Divider()

            inputView
        }
        .background(
            ZStack {
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(0.95)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.cyan.opacity(0.03),
                        Color.blue.opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .foregroundColor(.blue)
            Text("AI Assistant")
                .font(.headline)
            Spacer()

            // Live status dot
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: aiService.isModelLoaded)
                Text(aiService.isModelLoaded ? "Model Ready" : "No Model")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
    }

    private var statusColor: Color {
        if isWaitingForResponse { return .blue }
        if aiService.isModelLoaded { return .green }
        return .orange
    }

    // MARK: - Model Status Banner

    private var modelStatusBanner: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "cpu")
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Offline AI Model")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(aiService.modelStatus)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }

            // Loading progress bar (visible while loading)
            let progress = MLXModelManager.shared.loadingProgress
            if progress > 0 && progress < 1.0 {
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.blue)
                    Text("\(Int(progress * 100))% — \(MLXModelManager.shared.statusMessage)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 8) {
                Button {
                    aiService.refreshModelSearch()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)

                Spacer()

                if MLXModelManager.shared.modelPath != nil {
                    Button {
                        Task { await aiService.loadModel() }
                    } label: {
                        Label("Load AI Model", systemImage: "play.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(MLXModelManager.shared.isLoading)
                }
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.06))
    }

    // MARK: - Messages

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messages.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        // Typing indicator shown while waiting for first token
                        if isWaitingForResponse && messages.last?.isStreaming != true {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                }
                .padding()
            }
            // Scroll to bottom on every new message or content change
            .onChange(of: messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: messages.last?.content) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if let lastId = messages.last?.id {
                proxy.scrollTo(lastId, anchor: .bottom)
            } else if isWaitingForResponse {
                proxy.scrollTo("typing", anchor: .bottom)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: aiService.isModelLoaded ? "sparkles" : "cpu.fill")
                .font(.system(size: 48))
                .foregroundColor(aiService.isModelLoaded ? .blue : .orange)

            Text(aiService.isModelLoaded ? "Ask Me Anything" : "AI Not Loaded")
                .font(.title3)
                .fontWeight(.semibold)

            Text(aiService.isModelLoaded
                 ? "Ask me to explain, review, or improve your code."
                 : "Load the DeepSeek MLX model to enable AI inference.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Input

    private var inputView: some View {
        HStack(spacing: 8) {
            TextField("Ask about your code…", text: $inputText)
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .disabled(isWaitingForResponse)
                .onSubmit { sendMessage() }

            Button(action: sendMessage) {
                Image(systemName: isWaitingForResponse ? "stop.circle.fill" : "paperplane.fill")
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(sendButtonColor)
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.2), value: isWaitingForResponse)
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty && !isWaitingForResponse)
        }
        .padding(8)
    }

    private var sendButtonColor: Color {
        if isWaitingForResponse { return .red.opacity(0.8) }
        return inputText.isEmpty ? .gray : .blue
    }

    // MARK: - Send / Stream

    private func sendMessage() {
        guard !inputText.isEmpty, !isWaitingForResponse else { return }

        let question = inputText
        inputText = ""
        isWaitingForResponse = true

        // Add the user bubble
        messages.append(ChatMessage(content: question, isUser: true))

        Task {
            // Insert a placeholder AI bubble that will be filled token by token.
            // isStreaming = true shows the blinking cursor immediately.
            await MainActor.run {
                messages.append(ChatMessage(
                    content: "",
                    isUser: false,
                    isStreaming: true
                ))
            }

            // Index of the AI bubble we just inserted
            let bubbleIndex = messages.count - 1

            // Consume the token stream
            let stream = aiService.analyzeCode(
                code: appState.fileContent,
                language: appState.selectedFile?.fileType.rawValue ?? "text",
                question: question
            )

            for await token in stream {
                await MainActor.run {
                    messages[bubbleIndex].content += token
                }
            }

            // Streaming done — remove cursor and re-enable input
            await MainActor.run {
                messages[bubbleIndex].isStreaming = false
                isWaitingForResponse = false
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    /// Cursor blink state (only used while streaming)
    @State private var cursorVisible: Bool = true

    var body: some View {
        HStack {
            if message.isUser { Spacer() }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Message content + optional blinking cursor
                HStack(alignment: .bottom, spacing: 0) {
                    Text(message.content)
                        .padding(12)
                        .background(message.isUser
                                    ? Color.blue
                                    : Color(NSColor.controlBackgroundColor))
                        .foregroundColor(message.isUser ? .white : .primary)
                        .cornerRadius(12)
                        .textSelection(.enabled)

                    // Blinking cursor while streaming
                    if message.isStreaming {
                        Text("▊")
                            .foregroundColor(.blue)
                            .opacity(cursorVisible ? 1 : 0)
                            .animation(
                                .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                                value: cursorVisible
                            )
                            .onAppear { cursorVisible.toggle() }
                    }
                }

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser { Spacer() }
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotCount = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 6, height: 6)
                        .opacity(dotCount > index ? 1 : 0.3)
                        .animation(.easeInOut(duration: 0.4), value: dotCount)
                }
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)

            Spacer()
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}

#Preview {
    ChatPanelView()
        .environmentObject(AppState())
        .frame(width: 350, height: 600)
}
