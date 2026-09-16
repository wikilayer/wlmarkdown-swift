import Markdown

extension Dialect {
    /// Returns the reader-visible words in a markdown document.
    public func plainText(_ source: String) -> String {
        let document = Document(parsing: source)
        let reading = Reading(source, dialect: self)
        return squeezed(plainWords(in: document, reading: reading))
    }

    private func plainWords(in markup: any Markup, reading: Reading) -> String {
        if let quote = markup as? BlockQuote {
            if reading.unreadable(in: quote) != nil {
                return ""
            }
            if let place = reading.place(in: quote) {
                return plainText(place.caption)
            }
            if reading.calloutClass(of: quote) != nil {
                return wordsInside(quote, scan: reading.scan)
            }
        }

        switch markup {
        case let code as CodeBlock:
            return code.code
        case let code as InlineCode:
            return code.code
        case let text as Text:
            return text.string
        case is SoftBreak, is LineBreak:
            return " "
        case let item as ListItem:
            return withoutPlainTextTaskMark(children(of: item, reading: reading))
        default:
            break
        }
        return children(of: markup, reading: reading)
    }

    private func children(of markup: any Markup, reading: Reading) -> String {
        let children = Array(markup.children)
        let separator = children.allSatisfy { $0 is any InlineMarkup } ? "" : " "
        return children
            .map { plainWords(in: $0, reading: reading) }
            .filter { !$0.isEmpty }
            .joined(separator: separator)
    }

    private func withoutPlainTextTaskMark(_ spoken: String) -> String {
        for mark in ["[ ] ", "[x] ", "[X] "] where spoken.hasPrefix(mark) {
            return String(spoken.dropFirst(mark.count))
        }
        return spoken
    }
}
