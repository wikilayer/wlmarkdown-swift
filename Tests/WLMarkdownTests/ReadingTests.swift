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

    @Test func aCalloutNamesItsClassRatherThanItsMarker() {
        let (written, reading) = quote("> [!WARNING]\n> This cannot be undone.\n")
        #expect(reading.calloutClass(of: written) == "warning",
                "a host hangs a title and an icon on the class, not on the marker")
    }

    @Test func aMarkerSharingItsLineOpensNothing() {
        let (written, reading) = quote("> [!NOTE] see below\n> Body.\n")
        #expect(reading.calloutClass(of: written) == nil)
        #expect(!reading.opensAConstruct(written))
    }

    @Test func aPlaceKeepsItsCoordinatesDigitForDigit() {
        let (written, reading) = quote("> [!MAP]\n> 44.7866000, 20.4489\n> Belgrade.\n")
        let place = reading.place(in: written)
        #expect(place?.lat == "44.7866000",
                "a trailing zero dropped is a coordinate parsed into a number, which this dialect refuses")
        #expect(place?.lng == "20.4489")
        #expect(place?.caption == "Belgrade.")
    }

    @Test func wordsOutsideASCIIDoNotSplitACharacter() {
        let (written, reading) = quote("> [!MAP]\n> 44.7866, 20.4489\n> Кнез Михаилова, Београд\n")
        #expect(reading.place(in: written)?.caption == "Кнез Михаилова, Београд",
                "a cut between the halves of one letter loses the line")
    }

    @Test func aTabBeforeACaptionDoesNotEatIt() {
        let (written, reading) = quote("> [!MAP]\n> 44.7866, 20.4489\n> \t\tКнез Михаилова\n")
        #expect(reading.place(in: written)?.caption == "Кнез Михаилова",
                "a tab is one character and several columns, and counting it as one loses the tail")
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

    @Test func aPointNowhereOnEarthIsNotAPlace() {
        let (written, reading) = quote("> [!MAP]\n> 999, 20.4489\n")
        #expect(reading.place(in: written) == nil,
                "drawing a map of it puts the reader somewhere that is not where the page says")
        #expect(reading.unreadable(in: written) == "[!MAP] 999, 20.4489",
                "the words come back so a host can show what was written and say it cannot be read")
    }

    @Test func aQuoteThatIsNeitherOpensNothing() {
        let (written, reading) = quote("> Plain quoted words.\n")
        #expect(reading.calloutClass(of: written) == nil)
        #expect(reading.place(in: written) == nil)
        #expect(!reading.opensAConstruct(written))
    }

    @Test func aDestinationNamesItsSchemeOrNone() {
        let dialect = Dialect()
        #expect(dialect.scheme(in: "page:home") == "page",
                "what follows a scheme is as often a name as a number")
        #expect(dialect.scheme(in: "block:50386") == "block")
        #expect(dialect.scheme(in: "https://example.invalid/page") == nil)
    }
}
