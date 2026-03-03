import SwiftUI
import AppKit

struct CodeEditorWithLineNumbers: View {
    @Binding var text: String
    let language: FileType
    
    var body: some View {
        EditorWithGutter(text: $text, language: language)
    }
}

struct EditorWithGutter: NSViewRepresentable {
    @Binding var text: String
    let language: FileType
    
    func makeNSView(context: Context) -> NSScrollView {
        // Create scroll view
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        // Configure text view
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textContainerInset = CGSize(width: 10, height: 10)
        textView.allowsUndo = true
        textView.delegate = context.coordinator
        
        // Add line number ruler
        let lineNumberView = LineNumberRulerView(textView: textView)
        scrollView.verticalRulerView = lineNumberView
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        
        // Observe scroll changes
        NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: .main
        ) { _ in
            lineNumberView.needsDisplay = true
        }
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Update content
        if textView.string != text {
            let highlighted = SyntaxHighlighter.highlight(text, language: language)
            textView.textStorage?.setAttributedString(highlighted)
        }
        
        // Refresh line numbers
        if let lineNumberView = nsView.verticalRulerView as? LineNumberRulerView {
            lineNumberView.needsDisplay = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorWithGutter
        
        init(_ parent: EditorWithGutter) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            let currentText = textView.string
            parent.text = currentText
            
            let highlighted = SyntaxHighlighter.highlight(currentText, language: parent.language)
            
            let selectedRange = textView.selectedRange()
            textView.textStorage?.setAttributedString(highlighted)
            textView.setSelectedRange(selectedRange)
            
            // Update line numbers
            if let scrollView = textView.enclosingScrollView,
               let lineNumberView = scrollView.verticalRulerView as? LineNumberRulerView {
                lineNumberView.needsDisplay = true
            }
        }
    }
}

class LineNumberRulerView: NSRulerView {
    weak var textView: NSTextView?
    
    init(textView: NSTextView) {
        self.textView = textView
        super.init(scrollView: textView.enclosingScrollView!, orientation: .verticalRuler)
        self.clientView = textView
        self.ruleThickness = 45
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = self.textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer,
              let context = NSGraphicsContext.current?.cgContext else {
            return
        }
        
        // Background
        NSColor.controlBackgroundColor.setFill()
        context.fill(self.bounds)
        
        // Font
        let font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        let textColor = NSColor.secondaryLabelColor
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        // Get visible rect
        let visibleRect = scrollView?.documentVisibleRect ?? textView.visibleRect
        
        // Get text
        let text = textView.string as NSString
        
        // Calculate visible range
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        // Calculate line number for first visible character
        var lineNumber = 1
        if charRange.location > 0 {
            let prefixText = text.substring(to: charRange.location)
            lineNumber = prefixText.components(separatedBy: "\n").count
        }
        
        // Iterate through visible lines
        var index = charRange.location
        
        while index < NSMaxRange(charRange) && index < text.length {
            let lineRange = text.lineRange(for: NSRange(location: index, length: 0))
            
            if lineRange.length == 0 { break }
            
            // Get glyph range
            let glyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
            
            // Get line rect
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil)
            
            // Calculate Y position
            let yPosition = lineRect.origin.y + textView.textContainerInset.height - visibleRect.origin.y
            
            // Draw if visible
            if yPosition >= -20 && yPosition <= self.bounds.height + 20 {
                let lineStr = "\(lineNumber)"
                let size = lineStr.size(withAttributes: attributes)
                
                let xPosition = self.ruleThickness - size.width - 8
                let point = NSPoint(x: xPosition, y: yPosition)
                
                lineStr.draw(at: point, withAttributes: attributes)
            }
            
            lineNumber += 1
            index = NSMaxRange(lineRange)
        }
        
        // Separator line
        NSColor.separatorColor.setStroke()
        let separator = NSBezierPath()
        separator.move(to: NSPoint(x: self.bounds.width - 0.5, y: 0))
        separator.line(to: NSPoint(x: self.bounds.width - 0.5, y: self.bounds.height))
        separator.lineWidth = 1
        separator.stroke()
    }
}

#Preview {
    CodeEditorWithLineNumbers(
        text: .constant("""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Test</title>
        </head>
        <body>
            <h1>Hello World</h1>
        </body>
        </html>
        """),
        language: .html
    )
    .frame(width: 800, height: 600)
}
