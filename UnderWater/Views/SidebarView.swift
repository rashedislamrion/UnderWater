//
//  SidebarView.swift
//  UnderWater
//
//  Created by UnderWater AI on 15/2/26.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var hoveredFileId: UUID?
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with "Open Project" button
            VStack(spacing: 8) {
                HStack {
                    Text("Files")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                Button(action: openProjectAction) {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text(appState.projectURL == nil ? "Open Project" : "Change Project")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                if let projectURL = appState.projectURL {
                    Text(projectURL.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .truncationMode(.middle)
                    
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search files...", text: $searchText)
                            .textFieldStyle(.plain)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    .padding(.top, 4)
                }
            }
            .padding()
            
            Divider()
            
            // File List
            List {
                if appState.projectURL == nil {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("No Project Open")
                            .font(.headline)
                        
                        Text("Click 'Change Project' to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                } else if appState.projectFiles.isEmpty && appState.projectURL != nil {
                     Text("No files found or empty directory")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ForEach(filteredFiles) { item in
                        FileRowView(item: item, level: 0)
                    }
                }
            }
            .listStyle(.sidebar)
            
            // Footer
            if !appState.projectFiles.isEmpty {
                VStack(spacing: 4) {
                    Divider()
                    
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.secondary)
                        Text("\(totalFileCount) files")
                            .font(.caption)
                        
                        Spacer()
                        
                        if let url = appState.projectURL {
                            Text(url.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .background(
            ZStack {
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(0.95)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.03),
                        Color.purple.opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }
    
    private var filteredFiles: [FileItem] {
        if searchText.isEmpty {
            return appState.projectFiles
        } else {
            // Simple flat filter for top-level search, or recursive search?
            // Requirement says: appState.projectFiles.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            // But projectFiles is a tree. The requirement snippet implies filtering top level. 
            // However, a true search should probably flatten or search deeply.
            // Following requirement implementation strictly for "Simple" search logic as requested in prompt.
            // Wait, the requirement code provided in prompt:
            // let filteredFiles = searchText.isEmpty ? 
            //    appState.projectFiles : 
            //    appState.projectFiles.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            // This only filters top level items. If the user wants to find a file deep inside, this won't work unless
            // the recursive structure is handled. 
            // However, implementing complex recursive filtering might be "too much" for Day 4 simple search.
            // But let's verify if `appState.projectFiles` is flat or tree. It is a tree.
            // So this simple filter only filters top level folders/files.
            // Let's implement it as requested.
            return appState.projectFiles.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var totalFileCount: Int {
        // Count all files recursively
        func countFiles(in items: [FileItem]) -> Int {
            items.reduce(0) { count, item in
                if item.isDirectory {
                    return count + countFiles(in: item.children ?? [])
                }
                return count + 1
            }
        }
        return countFiles(in: appState.projectFiles)
    }
    
    private func openProjectAction() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select a project directory"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                appState.openProject(url: url)
            }
        }
    }
}

struct FileRowView: View {
    let item: FileItem
    let level: Int
    @EnvironmentObject var appState: AppState
    @State private var isExpanded: Bool = false
    
    var body: some View {
        Group {
            Button(action: {
                if item.isDirectory {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } else {
                    appState.selectFile(item)
                }
            }) {
                HStack {
                    // Indentation
                    ForEach(0..<level, id: \.self) { _ in
                        Spacer().frame(width: 12)
                    }
                    
                    // Icon
                    if item.isDirectory {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 10)
                        
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.blue)
                    } else {
                        Spacer().frame(width: 10) // Alignment for file w/o chevron
                        Image(systemName: item.fileType.icon)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(item.name)
                        .foregroundStyle(appState.selectedFile?.id == item.id ? Color.accentColor : .primary)
                    
                    Spacer()
                }
                .contentShape(Rectangle()) // Make full row clickable
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
            .contextMenu {
                Button("Copy Path") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(item.url.path, forType: .string)
                }
                
                Button("Show in Finder") {
                    NSWorkspace.shared.selectFile(item.url.path, inFileViewerRootedAtPath: "")
                }
                
                if !item.isDirectory {
                    Button("Copy File Name") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(item.name, forType: .string)
                    }
                }
            }
            
            // Recursive children
            if isExpanded, let children = item.children {
                ForEach(children) { child in
                    FileRowView(item: child, level: level + 1)
                }
            }
        }
    }
}

#Preview {
    SidebarView()
        .environmentObject(AppState())
        .frame(width: 250, height: 600)
}
