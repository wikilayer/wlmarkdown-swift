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
        gather(document, into: &turnedDown)
        return turnedDown
    }

    private func gather(_ markup: any Markup, into turnedDown: inout [Declined]) {
        if let quote = markup as? BlockQuote,
           place(in: quote) == nil,
           unreadable(in: quote) == nil,
           calloutClass(of: quote) == nil,
           opensAConstruct(quote) {
            turnedDown.append(Declined(marker: scan.openingLine(of: quote)))
        }
        for child in markup.children {
            gather(child, into: &turnedDown)
        }
    }
}
