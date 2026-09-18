import Foundation
import Markdown

extension Dialect {
    /// Returns dialect constructs in document order.
    public func recognise(_ source: String) -> [Found] {
        var found: [Found] = []
        let scan = Scan(dialect: self, source: source)
        gather(Document(parsing: source).children, scan: scan, into: &found)
        return found
    }

    private func gather(
        _ children: some Sequence<any Markup>,
        scan: Scan,
        into found: inout [Found]
    ) {
        for child in children {
            gather(child, scan: scan, into: &found)
        }
    }

    private func gather(_ markup: any Markup, scan: Scan, into found: inout [Found]) {
        switch markup {
        case let quote as BlockQuote:
            gather(quote: quote, scan: scan, into: &found)
        case let link as Markdown.Link:
            if let written = reported(link, scan: scan) {
                found.append(written)
            }
        default:
            gather(markup.children, scan: scan, into: &found)
        }
    }

    private func reported(_ link: Markdown.Link, scan: Scan) -> Found? {
        guard !scan.isAutolink(link) else { return nil }
        let destination = link.destination ?? ""
        return Found(
            kind: "link",
            scheme: schemeIn(destination),
            destination: destination,
            text: squeezed(words(of: link))
        )
    }

    private func gather(quote: BlockQuote, scan: Scan, into found: inout [Found]) {
        let opening = scan.openingLine(of: quote)

        if opening == rules.mapMarker, let place = place(in: quote, scan: scan) {
            found.append(place)
            return
        }

        if let calloutClass = rules.calloutClassByMarker[opening] {
            found.append(Found(
                kind: "callout",
                class: calloutClass,
                text: wordsInside(quote, scan: scan)
            ))
            gather(insideCallout: quote, scan: scan, into: &found)
            return
        }

        gather(forLinksOnly: quote, scan: scan, into: &found)
    }

    private func gather(insideCallout quote: BlockQuote, scan: Scan, into found: inout [Found]) {
        for child in quote.children {
            guard let inner = child as? BlockQuote else {
                gather(child, scan: scan, into: &found)
                continue
            }
            if scan.openingLine(of: inner) == rules.mapMarker,
               let place = place(in: inner, scan: scan) {
                found.append(place)
                continue
            }
            gather(forLinksOnly: inner, scan: scan, into: &found)
        }
    }

    private func gather(forLinksOnly markup: any Markup, scan: Scan, into found: inout [Found]) {
        for child in markup.children {
            if let inner = child as? Markdown.Link {
                if let written = reported(inner, scan: scan) {
                    found.append(written)
                }
                continue
            }
            gather(forLinksOnly: child, scan: scan, into: &found)
        }
    }
}
