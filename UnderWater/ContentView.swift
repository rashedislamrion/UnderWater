import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        HSplitView {
            // Left Panel: File Browser
            SidebarView()
                .environmentObject(appState)
                .frame(minWidth: 200, idealWidth: 280, maxWidth: 350)
                .layoutPriority(0)
            
            // Middle Panel: Code Editor
            EditorView()
                .environmentObject(appState)
                .frame(minWidth: 400)
                .layoutPriority(1)
            
            // Right Panel: AI Chat
            ChatPanelView()
                .environmentObject(appState)
                .frame(minWidth: 250, idealWidth: 350, maxWidth: 450)
                .layoutPriority(0)
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}

#Preview {
    ContentView()
}
