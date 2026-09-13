import Foundation
import Markdown
import SwiftEmbed
import Testing
@testable import WLMarkdown

struct CorpusTests {
    struct Case: Codable {
        let name: String
        let markdown: String
        let found: [Found]
        let declined: [String]?
    }

    struct Corpus: Codable {
        let cases: [Case]
    }

    struct Written: CustomTestStringConvertible {
        let name: String
        let markdown: String
        let found: [Found]
        let declined: [Declined]

        var testDescription: String { name }
    }

    static var written: [Written] {
        let corpus: Corpus = Embedded.getYAML(Bundle.module, path: "dialect.yaml")
        return corpus.cases.map {
            Written(
                name: $0.name,
                markdown: $0.markdown,
                found: $0.found,
                declined: ($0.declined ?? []).map { Declined(marker: $0) }
            )
        }
    }

    @Test("the dialect answers every case the corpus defines it by", arguments: written)
    func recognises(_ written: Written) {
        let found = Dialect().recognise(written.markdown)
        #expect(found == written.found, "\(written.name): recognised \(found), the corpus names \(written.found)")
    }

    @Test("the dialect turns down every quote the corpus says it turns down", arguments: written)
    func turnsDown(_ written: Written) {
        let turnedDown = Reading(written.markdown).declined(in: Document(parsing: written.markdown))
        #expect(turnedDown == written.declined,
                "\(written.name): turned down \(turnedDown), the corpus names \(written.declined)")
    }

    @Test("a host asking about a quote it parsed itself is told what the corpus names", arguments: written)
    func answersAboutAQuote(_ written: Written) {
        let quotes = Document(parsing: written.markdown).children.compactMap { $0 as? BlockQuote }
        guard quotes.count == 1, written.found.count <= 1 else { return }

        let reading = Reading(written.markdown)
        let quote = quotes[0]
        let said = written.found.first

        #expect(reading.place(in: quote) == (said?.kind == "map" ? said : nil),
                "\(written.name): place(in:) answers about the quote differently from recognise")
        #expect(reading.unreadable(in: quote) == (said?.kind == "unreadable" ? said?.text : nil),
                "\(written.name): unreadable(in:) answers about the quote differently from recognise")
        #expect(reading.calloutClass(of: quote) == (said?.kind == "callout" ? said?.class : nil),
                "\(written.name): calloutClass(of:) answers about the quote differently from recognise")
    }

    @Test func theCorpusIsNotEmpty() {
        #expect(Self.written.count > 20, "an empty corpus cannot fail")
        #expect(Self.written.allSatisfy { !$0.markdown.isEmpty }, "a case with no markdown proves nothing")
    }
}
