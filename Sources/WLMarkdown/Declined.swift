import Foundation
import Markdown

/// A dialect marker that was present in a quote the dialect left unchanged.
public struct Declined: Equatable, Sendable {
  /// The marker exactly as the dialect spells it.
  public let marker: String

  /// Creates a declined construct from its opening marker.
  public init(marker: String) {
    self.marker = marker
  }
}

extension Reading {
  /// Returns marked quotes the dialect declined to turn into constructs.
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
      opensAConstruct(quote)
    {
      turnedDown.append(Declined(marker: scan.openingLine(of: quote)))
    }
    for child in markup.children {
      gather(child, into: &turnedDown)
    }
  }
}
