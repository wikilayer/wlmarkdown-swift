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
        dialect.rules.calloutClassByMarker[scan.openingLine(of: quote)]
    }

    public func place(in quote: BlockQuote) -> Found? {
        guard scan.openingLine(of: quote) == dialect.rules.mapMarker else { return nil }
        return dialect.place(in: quote, scan: scan)
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
