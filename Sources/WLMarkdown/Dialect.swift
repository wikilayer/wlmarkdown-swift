import Foundation
import SwiftEmbed

struct Coordinate: Codable, Sendable {
    let signs: String
    let digits: String
    let point: String
    let latitudeWithin: String
    let longitudeWithin: String

    enum CodingKeys: String, CodingKey {
        case signs
        case digits
        case point
        case latitudeWithin = "latitude_within"
        case longitudeWithin = "longitude_within"
    }
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

enum Rulebook {
    static let bundle = Bundle.module
    static let file = "rules.yaml"
}

public struct Dialect: Sendable {
    let rules: Rules

    private static let written: Rules = Embedded.getYAML(Rulebook.bundle, path: Rulebook.file)

    public init() {
        rules = Self.written
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
