import Foundation
import Markdown

struct Scan {
    let dialect: Dialect
    let lines: [String]

    init(dialect: Dialect, source: String) {
        self.dialect = dialect
        lines = source.components(separatedBy: "\n")
    }

    func raw(from: SourceLocation, to: SourceLocation) -> String {
        guard from.line == to.line, from.line >= 1, from.line <= lines.count else {
            return ""
        }
        let held = lines[from.line - 1]
        let spelled = held.utf8
        guard let start = spelled.index(
            spelled.startIndex, offsetBy: max(from.column - 1, 0), limitedBy: spelled.endIndex
        ), let end = spelled.index(
            start, offsetBy: max(to.column - from.column, 0), limitedBy: spelled.endIndex
        ) else {
            return ""
        }
        return String(held[start..<end])
    }

    func rawLines(of paragraph: Paragraph) -> [String] {
        var written: [String] = []
        var line: [any InlineMarkup] = []

        func close() {
            let ranged = line.compactMap { inline -> (SourceLocation, SourceLocation)? in
                guard let range = inline.range else { return nil }
                return (range.lowerBound, range.upperBound)
            }
            guard let first = ranged.first, let last = ranged.last else {
                written.append(line.map { dialect.words(of: $0) }.joined())
                return
            }
            written.append(raw(from: first.0, to: last.1))
        }

        for inline in paragraph.inlineChildren {
            if inline is SoftBreak || inline is LineBreak {
                close()
                line = []
                continue
            }
            line.append(inline)
        }
        close()
        return written
    }

    func inlineLines(of paragraph: Paragraph) -> [[any InlineMarkup]] {
        var written: [[any InlineMarkup]] = []
        var line: [any InlineMarkup] = []
        for inline in paragraph.inlineChildren {
            if inline is SoftBreak || inline is LineBreak {
                written.append(line)
                line = []
                continue
            }
            line.append(inline)
        }
        written.append(line)
        return written
    }

    func isAutolink(_ link: Markdown.Link) -> Bool {
        guard let range = link.range else { return false }
        return raw(from: range.lowerBound, to: range.upperBound).hasPrefix("<")
    }
}
