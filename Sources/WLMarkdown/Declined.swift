import Foundation
import Markdown

public struct Declined: Equatable, Sendable {
    public let marker: String

    public init(marker: String) {
        self.marker = marker
    }
}

extension Reading {
    public func declined(in document: Document) -> [Declined] {
        var turnedDown: [Declined] = []
        gather(document.children, claimed: false, into: &turnedDown)
        return turnedDown
    }

    private func gather(
        _ children: some Sequence<any Markup>,
        claimed: Bool,
        into turnedDown: inout [Declined]
    ) {
        for child in children {
            guard let quote = child as? BlockQuote else {
                gather(child.children, claimed: claimed, into: &turnedDown)
                continue
            }
            gather(quote: quote, claimed: claimed, into: &turnedDown)
        }
    }

    private func gather(quote: BlockQuote, claimed: Bool, into turnedDown: inout [Declined]) {
        if place(in: quote) != nil {
            return
        }
        let opening = scan.openingLine(of: quote)
        if !claimed, calloutClass(of: quote) != nil {
            gather(quote.children, claimed: true, into: &turnedDown)
            return
        }
        if opensAConstruct(quote) {
            turnedDown.append(Declined(marker: opening))
        }
        gather(quote.children, claimed: claimed, into: &turnedDown)
    }
}
