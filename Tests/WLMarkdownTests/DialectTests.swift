import Foundation
import SwiftEmbed
import Testing
@testable import WLMarkdown

struct Written: Codable {
    let calloutClassByMarker: [String: String]
    let mapMarker: String
    let refSchemes: [String]

    enum CodingKeys: String, CodingKey {
        case calloutClassByMarker = "callout_class_by_marker"
        case mapMarker = "map_marker"
        case refSchemes = "ref_schemes"
    }
}

struct DialectTests {
    static var rules: Written {
        Embedded.getYAML(Rulebook.bundle, path: Rulebook.file)
    }

    @Test func everyMarkerTheRulesNameCarriesItsClass() {
        let written = Self.rules.calloutClassByMarker
        #expect(!written.isEmpty, "with no markers this test cannot fail")
        for (marker, calloutClass) in written {
            let found = Dialect().recognise("> \(marker)\n> Body.\n")
            #expect(
                found == [Found(kind: "callout", class: calloutClass, text: "Body.")],
                "\(marker) should carry class \(calloutClass), recognised \(found)"
            )
        }
    }

    @Test func theMarkersOnOfferAreEveryOneTheRulesName() {
        let written = Self.rules
        let want = (Array(written.calloutClassByMarker.keys) + [written.mapMarker]).sorted()
        #expect(Dialect().markers == want, "offered \(Dialect().markers), the rules name \(want)")
    }

    @Test func theClassesOnOfferAreTheOnesTheRulesName() {
        let want = Array(Set(Self.rules.calloutClassByMarker.values)).sorted()
        #expect(Dialect().classes == want, "offered \(Dialect().classes), the rules name \(want)")
    }

    @Test func theSchemesOnOfferAreTheOnesTheRulesName() {
        let want = Self.rules.refSchemes.sorted()
        #expect(Dialect().schemes == want, "offered \(Dialect().schemes), the rules name \(want)")
    }

    @Test func everySchemeTheRulesNameIsReadAsOne() {
        for scheme in Self.rules.refSchemes {
            let found = Dialect().recognise("A [label](\(scheme):1).\n")
            #expect(
                found == [Found(kind: "link", scheme: scheme, destination: "\(scheme):1", text: "label")],
                "\(scheme) should be read as a scheme, recognised \(found)"
            )
        }
    }

    @Test func theMarkerTheRulesNameOpensAPlace() {
        let found = Dialect().recognise("> \(Self.rules.mapMarker)\n> 44.7866, 20.4489\n")
        #expect(found.first?.kind == "map", "the map marker went unrecognised: \(found)")
    }
}
