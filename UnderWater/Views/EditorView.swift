import SwiftUI

struct EditorView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            if let file = appState.selectedFile {
                // Enhanced top bar
                fileHeaderView(file)
                
                Divider()
                
                // Editor with line numbers — editable, binding keeps AppState in sync
                CodeEditorWithLineNumbers(
                    text: $appState.fileContent,
                    language: file.fileType
                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: file.id)
            } else {
                emptyStateView
            }
        }
    }
    
    private func fileHeaderView(_ file: FileItem) -> some View {
        VStack(spacing: 8) {
            // File name and icon
            HStack {
                Image(systemName: file.fileType.icon)
                    .foregroundColor(.blue)
                Text(file.name)
                    .font(.headline)
                
                Spacer()
                
                // Copy button
                Button(action: copyContent) {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                
                // Open in Finder
                Button(action: { openInFinder(file) }) {
                    Label("Show", systemImage: "folder")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
            
            // File path
            HStack(spacing: 4) {
                Image(systemName: "folder")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(file.url.path)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
            }
            
            Divider()
            
            // Stats bar
            HStack(spacing: 16) {
                Label("\(lineCount) lines", systemImage: "text.alignleft")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(wordCount) words", systemImage: "text.word.spacing")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(characterCount) chars", systemImage: "character")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Language badge
                Text(file.fileType.rawValue.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(languageColor(file.fileType).opacity(0.2))
                    .foregroundColor(languageColor(file.fileType))
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .background(
            ZStack {
                // Liquid glass – macOS translucent material
                Color.clear
                    .background(.thinMaterial)
                // Subtle gradient sheen
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.04),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No File Selected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Select a file from the sidebar to view its contents")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if appState.projectURL == nil {
                Divider()
                    .padding(.horizontal, 100)
                
                VStack(spacing: 12) {
                    Text("Get Started")
                        .font(.headline)
                    
                    Text("Open a project folder to begin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // Helper computed properties
    private var lineCount: Int {
        appState.fileContent.components(separatedBy: .newlines).count
    }
    
    private var wordCount: Int {
        appState.fileContent.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
    }
    
    private var characterCount: Int {
        appState.fileContent.count
    }
    
    // Helper functions
    private func copyContent() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(appState.fileContent, forType: .string)
    }
    
    private func openInFinder(_ file: FileItem) {
        NSWorkspace.shared.selectFile(file.url.path, inFileViewerRootedAtPath: "")
    }
    
    private func languageColor(_ type: FileType) -> Color {
        switch type {
        case .html: return .orange
        case .javascript: return .yellow
        case .css: return .blue
        case .swift: return .orange
        case .python: return .green
        case .json: return .purple
        default: return .gray
        }
    }
}

#Preview {
    EditorView()
        .environmentObject(AppState())
        .frame(width: 600, height: 800)
}
