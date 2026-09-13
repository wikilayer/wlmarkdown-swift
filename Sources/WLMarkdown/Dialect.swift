import Foundation
import SwiftEmbed

struct Coordinate: Codable, Sendable {
    let signs: String
    let digits: String
    let point: String
}

struct Rules: Codable, Sendable {
    let calloutClassByMarker: [String: String]
    let mapMarker: String
    let coordinate: Coordinate
    let blanks: String
    let refSchemes: [String]

    enum CodingKeys: String, CodingKey {
        case calloutClassByMarker = "callout_class_by_marker"
        case mapMarker = "map_marker"
        case coordinate
        case blanks
        case refSchemes = "ref_schemes"
    }
}

public struct Dialect: Sendable {
    let rules: Rules

    public init() {
        rules = Embedded.getYAML(Bundle.module, path: "rules.yaml")
    }

    public var markers: [String] {
        (Array(rules.calloutClassByMarker.keys) + [rules.mapMarker]).sorted()
    }

    public var classes: [String] {
        Array(Set(rules.calloutClassByMarker.values)).sorted()
    }

    public var schemes: [String] {
        rules.refSchemes.sorted()
    }
}
