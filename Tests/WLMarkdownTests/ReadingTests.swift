import Markdown
import Testing
@testable import WLMarkdown

struct ReadingTests {
    private func quote(_ source: String) -> (BlockQuote, Reading) {
        let document = Document(parsing: source)
        guard let quote = document.child(at: 0) as? BlockQuote else {
            fatalError("the source of this test is not a quote, so the test proves nothing")
        }
        return (quote, Reading(source))
    }

    @Test func aQuoteCarryingAMarkerSaysSo() {
        let (marked, reading) = quote("> [!MAP]\n> not a point at all\n")
        #expect(reading.opensAConstruct(marked),
                "a host looking for what the dialect turned down starts from this answer")

        let (plain, plainly) = quote("> Plain quoted words.\n")
        #expect(!plainly.opensAConstruct(plain))

        let (sharing, shared) = quote("> [!NOTE] see below\n> Body.\n")
        #expect(!shared.opensAConstruct(sharing),
                "a marker sharing its line was never a candidate")
    }

    @Test func whatAnOrdinaryQuoteHidesIsNotAConstruct() {
        let source = "> Plain quoted words.\n>\n> > [!MAP]\n> > 44.7866, 20.4489\n"
        let reading = Reading(source)
        let inner = Document(parsing: source)
            .children.compactMap { $0 as? BlockQuote }
            .flatMap { $0.children.compactMap { $0 as? BlockQuote } }

        #expect(inner.count == 1, "the source of this test no longer nests a quote")
        #expect(inner.first.flatMap { reading.place(in: $0) } == nil,
                "an ordinary quote stops the dialect, and a host must get the answer recognise gives")
    }

    @Test func aDestinationNamesItsSchemeOrNone() {
        let dialect = Dialect()
        #expect(dialect.scheme(in: "page:home") == "page",
                "what follows a scheme is as often a name as a number")
        #expect(dialect.scheme(in: "block:50386") == "block")
        #expect(dialect.scheme(in: "https://example.invalid/page") == nil)
    }
}
