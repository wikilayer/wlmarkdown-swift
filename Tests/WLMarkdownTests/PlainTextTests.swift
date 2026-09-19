import Foundation
import SwiftEmbed
import Testing

@testable import WLMarkdown

struct PlainTextTests {
  struct Case: Codable, CustomTestStringConvertible {
    let name: String
    let markdown: String
    let plain: String

    var testDescription: String { name }
  }

  struct Corpus: Codable {
    let cases: [Case]
  }

  static let cases: [Case] = {
    let corpus: Corpus = Embedded.getYAML(Bundle.module, path: "plain_text.yaml")
    return corpus.cases
  }()

  @Test("plainText answers the shared corpus", arguments: cases)
  func strips(_ written: Case) {
    #expect(Dialect().plainText(written.markdown) == written.plain)
  }

  @Test func theCorpusIsNotEmpty() {
    #expect(!Self.cases.isEmpty)
  }
}
