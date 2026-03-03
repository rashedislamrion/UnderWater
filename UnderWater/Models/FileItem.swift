import Foundation

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let isDirectory: Bool
    let fileType: FileType
    var children: [FileItem]?
}

enum FileType: String {
    case swift, kotlin, java, javascript, python
    case html, css, json, markdown, text, other
    
    static func from(extension ext: String) -> FileType {
        switch ext.lowercased() {
        case "swift": return .swift
        case "kt", "kts": return .kotlin
        case "java": return .java
        case "js", "jsx", "ts", "tsx": return .javascript
        case "py": return .python
        case "html", "htm": return .html
        case "css": return .css
        case "json": return .json
        case "md": return .markdown
        case "txt": return .text
        default: return .other
        }
    }
    
    var icon: String {
        switch self {
        case .swift: return "swift"
        case .kotlin: return "k.square.fill"
        case .java: return "cup.and.saucer.fill"
        case .javascript: return "curlybraces"
        case .python: return "p.square.fill"
        case .html: return "globe"
        case .css: return "paintbrush.fill"
        case .json: return "doc.text.fill"
        case .markdown: return "doc.richtext.fill"
        case .text: return "doc.text"
        case .other: return "doc"
        }
    }
}
