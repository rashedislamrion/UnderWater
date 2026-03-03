import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var projectURL: URL?
    @Published var projectFiles: [FileItem] = []
    @Published var selectedFile: FileItem?
    @Published var fileContent: String = """
    // Welcome to UnderWater
    // Select a file from the sidebar to view its contents
    """
    
    @Published var isLoadingFile: Bool = false
    @Published var errorMessage: String?
    
    func openProject(url: URL) {
        projectURL = url
        projectFiles = scanDirectory(at: url)
    }
    
    func selectFile(_ file: FileItem) {
        guard !file.isDirectory else { return }
        
        selectedFile = file
        isLoadingFile = true
        errorMessage = nil
        
        Task { @MainActor in
            // Simulate network/disk delay for effect if desired, or just load
            // For now, sticking to the requested implementation which puts it in a Task
            
            do {
                // Using a slightly different approach than before to ensure main actor updates
                // and to actually make it async-ish even though local file access is fast
                let content = try String(contentsOf: file.url, encoding: .utf8)
                fileContent = content
                isLoadingFile = false
            } catch {
                errorMessage = "Failed to load file: \(error.localizedDescription)"
                fileContent = "// Error loading file"
                isLoadingFile = false
            }
        }
    }
    
    private func scanDirectory(at url: URL, depth: Int = 0, maxDepth: Int = 3) -> [FileItem] {
        guard depth < maxDepth else { return [] }
        
        var items: [FileItem] = []
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            
            for itemURL in contents {
                let name = itemURL.lastPathComponent
                
                // Skip common build folders
                if name == "node_modules" || name == ".git" || 
                   name == "build" || name == "DerivedData" {
                    continue
                }
                
                let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
                let isDirectory = resourceValues.isDirectory ?? false
                
                if isDirectory {
                    let children = scanDirectory(at: itemURL, depth: depth + 1, maxDepth: maxDepth)
                    if !children.isEmpty {
                        items.append(FileItem(
                            name: name,
                            url: itemURL,
                            isDirectory: true,
                            fileType: .other,
                            children: children
                        ))
                    }
                } else {
                    let ext = itemURL.pathExtension
                    let fileType = FileType.from(extension: ext)
                    
                    items.append(FileItem(
                        name: name,
                        url: itemURL,
                        isDirectory: false,
                        fileType: fileType,
                        children: nil
                    ))
                }
            }
        } catch {
            print("Error scanning directory: \(error)")
        }
        
        return items.sorted { $0.name < $1.name }
    }
}
