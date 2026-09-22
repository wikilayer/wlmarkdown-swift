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
  let marks: String
  let refSchemes: [String]

  enum CodingKeys: String, CodingKey {
    case calloutClassByMarker = "callout_class_by_marker"
    case mapMarker = "map_marker"
    case coordinate
    case blanks
    case marks
    case refSchemes = "ref_schemes"
  }
}

enum Rulebook {
  static let bundle = Bundle.module
  static let file = "rules.yaml"
}

/// The rules and readers of the WikiLayer markdown dialect.
public struct Dialect: Sendable {
  let rules: Rules

  private static let written: Rules = Embedded.getYAML(Rulebook.bundle, path: Rulebook.file)

  /// Creates the WikiLayer dialect from its bundled rules.
  public init() {
    rules = Self.written
  }

  /// Every marker that can open a dialect construct, in sorted order.
  public var markers: [String] {
    (Array(rules.calloutClassByMarker.keys) + [rules.mapMarker]).sorted()
  }

  /// Every callout class the dialect can report, in sorted order.
  public var classes: [String] {
    Array(Set(rules.calloutClassByMarker.values)).sorted()
  }

  /// Every node-reference scheme the dialect can report, in sorted order.
  public var schemes: [String] {
    rules.refSchemes.sorted()
  }
}
