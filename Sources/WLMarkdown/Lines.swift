import Foundation
import Markdown

extension Scan {
    func openingLine(of quote: BlockQuote) -> String {
        guard let paragraph = quote.child(at: 0) as? Paragraph,
              let opening = rawLines(of: paragraph).first
        else { return "" }
        return opening
    }
}

extension Dialect {
    var blankSet: CharacterSet {
        CharacterSet(charactersIn: rules.blanks)
    }

    func squeezed(_ spoken: String) -> String {
        spoken
            .components(separatedBy: blankSet)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    func schemeIn(_ destination: String) -> String {
        rules.refSchemes.first { destination.hasPrefix($0 + ":") } ?? ""
    }

    func within(_ spoken: String, _ bound: String) -> Bool {
        let unsigned = spoken.drop { rules.coordinate.signs.contains($0) }
        let parts = String(unsigned).components(separatedBy: rules.coordinate.point)
        let whole = parts[0].drop { $0 == "0" }
        if whole.isEmpty { return true }
        if whole.count != bound.count { return whole.count < bound.count }
        if whole != bound { return whole < bound }
        return parts.count == 1 || parts[1].allSatisfy { $0 == "0" }
    }

    func place(in quote: BlockQuote, scan: Scan) -> Found? {
        guard let paragraph = quote.child(at: 0) as? Paragraph else { return nil }
        let lines = scan.rawLines(of: paragraph)
        guard lines.count > 1 else { return nil }

        let written = lines[1].components(separatedBy: ",")
        guard written.count == 2 else { return nil }
        let lat = written[0].trimmingCharacters(in: blankSet)
        let lng = written[1].trimmingCharacters(in: blankSet)
        guard reads(lat), reads(lng) else { return nil }
        guard within(lat, rules.coordinate.latitudeWithin),
              within(lng, rules.coordinate.longitudeWithin)
        else {
            return Found(kind: "unreadable", text: asWritten(quote, scan: scan))
        }

        let caption = lines.dropFirst(2)
            .map { $0.trimmingCharacters(in: blankSet) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return Found(kind: "map", lat: lat, lng: lng, caption: caption)
    }

    func asWritten(_ quote: BlockQuote, scan: Scan) -> String {
        let spoken = quote.children.map { child -> String in
            guard let paragraph = child as? Paragraph else { return words(of: child) }
            return scan.rawLines(of: paragraph).joined(separator: " ")
        }
        return squeezed(spoken.joined(separator: " "))
    }

    func reads(_ spoken: String) -> Bool {
        var rest = Substring(spoken)
        if let first = rest.first, rules.coordinate.signs.contains(first) {
            rest = rest.dropFirst()
        }
        let parts = String(rest).components(separatedBy: rules.coordinate.point)
        guard parts.count <= 2, digitsOnly(parts[0]) else { return false }
        return parts.count == 1 || digitsOnly(parts[1])
    }

    private func digitsOnly(_ spoken: String) -> Bool {
        !spoken.isEmpty && spoken.allSatisfy { rules.coordinate.digits.contains($0) }
    }

    func wordsInside(_ quote: BlockQuote, scan: Scan) -> String {
        var spoken: [String] = []
        var openingDropped = false
        for child in quote.children {
            if let paragraph = child as? Paragraph, !openingDropped {
                openingDropped = true
                let body = scan.inlineLines(of: paragraph).dropFirst()
                spoken.append(body.map { line in line.map { words(of: $0) }.joined() }
                    .joined(separator: " "))
                continue
            }
            spoken.append(words(of: child, outside: scan))
        }
        return squeezed(spoken.joined(separator: " "))
    }

    func words(of markup: any Markup, outside scan: Scan? = nil) -> String {
        if let scan, let quote = markup as? BlockQuote, place(in: quote, scan: scan) != nil {
            return ""
        }
        switch markup {
        case is CodeBlock:
            return ""
        case let code as InlineCode:
            return code.code
        case let text as Text:
            return text.string
        case is SoftBreak, is LineBreak:
            return " "
        case let item as ListItem:
            return withoutTaskMark(item.children.map { words(of: $0, outside: scan) }
                .filter { !$0.isEmpty }
                .joined(separator: " "))
        default:
            break
        }
        if let inline = markup as? any InlineMarkup {
            return inline.children.map { words(of: $0, outside: scan) }.joined()
        }
        return markup.children
            .map { words(of: $0, outside: scan) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func withoutTaskMark(_ spoken: String) -> String {
        for mark in ["[ ] ", "[x] ", "[X] "] where spoken.hasPrefix(mark) {
            return String(spoken.dropFirst(mark.count))
        }
        return spoken
    }
}
