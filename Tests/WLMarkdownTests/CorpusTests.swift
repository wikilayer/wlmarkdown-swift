import Foundation
import SwiftEmbed
import Testing
@testable import WLMarkdown

struct CorpusTests {
    struct Case: Codable {
        let name: String
        let markdown: String
        let found: [Found]
    }

    struct Corpus: Codable {
        let cases: [Case]
    }

    struct Written: CustomTestStringConvertible {
        let name: String
        let markdown: String
        let found: [Found]

        var testDescription: String { name }
    }

    static var written: [Written] {
        let corpus: Corpus = Embedded.getYAML(Bundle.module, path: "dialect.yaml")
        return corpus.cases.map {
            Written(name: $0.name, markdown: $0.markdown, found: $0.found)
        }
    }

    @Test("the dialect answers every case the corpus defines it by", arguments: written)
    func recognises(_ written: Written) {
        let found = Dialect().recognise(written.markdown)
        #expect(found == written.found, "\(written.name): recognised \(found), the corpus names \(written.found)")
    }

    @Test func theCorpusIsNotEmpty() {
        #expect(Self.written.count > 20, "an empty corpus cannot fail")
        #expect(Self.written.allSatisfy { !$0.markdown.isEmpty }, "a case with no markdown proves nothing")
    }
}
