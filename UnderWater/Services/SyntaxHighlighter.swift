import Foundation
import AppKit

class SyntaxHighlighter {
    static func highlight(_ code: String, language: FileType) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: code)
        
        // Base styling
        let baseFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        let baseColor = NSColor.textColor
        attributed.addAttribute(.font, value: baseFont, range: NSRange(location: 0, length: code.count))
        attributed.addAttribute(.foregroundColor, value: baseColor, range: NSRange(location: 0, length: code.count))
        
        // Apply language-specific highlighting
        switch language {
        case .html:
            highlightHTML(attributed)
        case .javascript:
            highlightJavaScript(attributed)
        case .css:
            highlightCSS(attributed)
        case .swift:
            highlightSwift(attributed)
        case .python:
            highlightPython(attributed)
        case .json:
            highlightJSON(attributed)
        default:
            break
        }
        
        return attributed
    }
    
    private static func highlightHTML(_ text: NSMutableAttributedString) {
        let string = text.string
        
        // Tags: <html>, <div>, etc.
        highlightPattern(text, pattern: "<[^>]+>", color: .systemPurple)
        
        // Attributes: class="value"
        highlightPattern(text, pattern: "\\w+=\"[^\"]*\"", color: .systemBlue)
        
        // Comments: <!-- -->
        highlightPattern(text, pattern: "<!--[^>]*-->", color: .systemGreen)
    }
    
    private static func highlightJavaScript(_ text: NSMutableAttributedString) {
        // Keywords
        let keywords = ["function", "const", "let", "var", "if", "else", "return", "for", "while"]
        for keyword in keywords {
            highlightPattern(text, pattern: "\\b\(keyword)\\b", color: .systemPurple)
        }
        
        // Strings
        highlightPattern(text, pattern: "\"[^\"]*\"", color: .systemRed)
        highlightPattern(text, pattern: "'[^']*'", color: .systemRed)
        
        // Comments
        highlightPattern(text, pattern: "//.*", color: .systemGreen)
    }
    
    private static func highlightCSS(_ text: NSMutableAttributedString) {
        // Selectors
        highlightPattern(text, pattern: "\\.[a-zA-Z-]+", color: .systemYellow)
        highlightPattern(text, pattern: "#[a-zA-Z-]+", color: .systemYellow)
        
        // Properties
        highlightPattern(text, pattern: "[a-zA-Z-]+:", color: .systemBlue)
    }
    
    private static func highlightSwift(_ text: NSMutableAttributedString) {
        let keywords = ["func", "var", "let", "class", "struct", "import", "if", "else", "return"]
        for keyword in keywords {
            highlightPattern(text, pattern: "\\b\(keyword)\\b", color: .systemPurple)
        }
        
        highlightPattern(text, pattern: "\"[^\"]*\"", color: .systemRed)
        highlightPattern(text, pattern: "//.*", color: .systemGreen)
    }
    
    private static func highlightPython(_ text: NSMutableAttributedString) {
        let keywords = ["def", "class", "if", "else", "return", "import", "from"]
        for keyword in keywords {
            highlightPattern(text, pattern: "\\b\(keyword)\\b", color: .systemPurple)
        }
        
        highlightPattern(text, pattern: "\"[^\"]*\"", color: .systemRed)
        highlightPattern(text, pattern: "#.*", color: .systemGreen)
    }
    
    private static func highlightJSON(_ text: NSMutableAttributedString) {
        // Keys
        highlightPattern(text, pattern: "\"[^\"]+\":", color: .systemBlue)
        
        // String values
        highlightPattern(text, pattern: ":\\s*\"[^\"]*\"", color: .systemRed)
        
        // Numbers
        highlightPattern(text, pattern: "\\b\\d+\\b", color: .systemOrange)
    }
    
    private static func highlightPattern(_ text: NSMutableAttributedString, pattern: String, color: NSColor) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        let range = NSRange(location: 0, length: text.length)
        regex.enumerateMatches(in: text.string, range: range) { match, _, _ in
            if let matchRange = match?.range {
                text.addAttribute(.foregroundColor, value: color, range: matchRange)
            }
        }
    }
}
