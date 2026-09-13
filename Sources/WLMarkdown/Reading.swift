import Foundation
import Markdown

public struct Reading {
    let dialect: Dialect
    let scan: Scan

    public init(_ source: String, dialect: Dialect = Dialect()) {
        self.dialect = dialect
        scan = Scan(dialect: dialect, source: source)
    }

    public func calloutClass(of quote: BlockQuote) -> String? {
        guard quoteAbove(quote) == nil else { return nil }
        return dialect.rules.calloutClassByMarker[scan.openingLine(of: quote)]
    }

    public func place(in quote: BlockQuote) -> Found? {
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

    public func opensAConstruct(_ quote: BlockQuote) -> Bool {
        dialect.markers.contains(scan.openingLine(of: quote))
    }

    public func isAutolink(_ link: Markdown.Link) -> Bool {
        scan.isAutolink(link)
    }
}

extension Dialect {
    public func scheme(in destination: String) -> String? {
        let named = schemeIn(destination)
        return named.isEmpty ? nil : named
    }
}
