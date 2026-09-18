import Foundation
import Markdown

/// Answers dialect questions about a swift-markdown tree and its original source.
public struct Reading {
    let dialect: Dialect
    let scan: Scan

    /// Creates a reader for a document parsed from the same source string.
    public init(_ source: String, dialect: Dialect = Dialect()) {
        self.dialect = dialect
        scan = Scan(dialect: dialect, source: source)
    }

    /// Returns the class of a quote accepted as a callout at its position.
    public func calloutClass(of quote: BlockQuote) -> String? {
        guard quoteAbove(quote) == nil else { return nil }
        return dialect.rules.calloutClassByMarker[scan.openingLine(of: quote)]
    }

    /// Returns the placed map represented by a quote.
    public func place(in quote: BlockQuote) -> Found? {
        guard let written = written(in: quote), written.kind == "map" else { return nil }
        return written
    }

    /// Returns the source-preserving words of a map whose point lies outside the Earth.
    public func unreadable(in quote: BlockQuote) -> String? {
        guard let written = written(in: quote), written.kind == "unreadable" else { return nil }
        return written.text
    }

    private func written(in quote: BlockQuote) -> Found? {
        guard standsWhereTheDialectLooks(quote),
              scan.openingLine(of: quote) == dialect.rules.mapMarker
        else { return nil }
        return dialect.place(in: quote, scan: scan)
    }

    func quoteAbove(_ markup: any Markup) -> BlockQuote? {
        var walked = markup.parent
        while let above = walked {
            if let quote = above as? BlockQuote { return quote }
            walked = above.parent
        }
        return nil
    }

    func standsWhereTheDialectLooks(_ quote: BlockQuote) -> Bool {
        guard let above = quoteAbove(quote) else { return true }
        return calloutClass(of: above) != nil
    }

    /// Returns whether the quote starts with any marker known to the dialect.
    public func opensAConstruct(_ quote: BlockQuote) -> Bool {
        dialect.markers.contains(scan.openingLine(of: quote))
    }

    /// Returns whether the link was written in angle-bracket autolink form.
    public func isAutolink(_ link: Markdown.Link) -> Bool {
        scan.isAutolink(link)
    }
}

extension Dialect {
    /// Returns the dialect scheme at the start of a destination, when present.
    public func scheme(in destination: String) -> String? {
        let named = schemeIn(destination)
        return named.isEmpty ? nil : named
    }
}
