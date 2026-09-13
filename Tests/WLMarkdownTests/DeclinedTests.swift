import Markdown
import Testing
@testable import WLMarkdown

struct DeclinedTests {
    private func declined(_ source: String) -> [Declined] {
        Reading(source).declined(in: Document(parsing: source))
    }

    @Test func aPlaceWhoseCoordinatesDoNotReadIsTurnedDown() {
        #expect(declined("> [!MAP]\n> somewhere near the river\n") == [Declined(marker: "[!MAP]")],
                "the author cannot see why no map appeared, and neither can the host")
    }

    @Test func aCalloutInsideACalloutIsTurnedDown() {
        let inner = declined("> [!NOTE]\n> Outer.\n>\n> > [!TIP]\n> > Inner.\n")
        #expect(inner == [Declined(marker: "[!TIP]")],
                "the inner quote stands unclaimed and should say so")
    }

    @Test func whatTheDialectMadeIsNotTurnedDown() {
        #expect(declined("> [!NOTE]\n> Body.\n\n> [!MAP]\n> 44.7866, 20.4489\n").isEmpty)
    }

    @Test func aMarkerSharingItsLineIsNotTurnedDown() {
        #expect(declined("> [!NOTE] see below\n> Body.\n").isEmpty,
                "that quote was never a candidate, so calling it declined cries wolf")
    }

    @Test func aPlaceInsideACalloutIsStillMade() {
        #expect(declined("> [!NOTE]\n> Where.\n>\n> > [!MAP]\n> > 44.7866, 20.4489\n").isEmpty)
    }
}
