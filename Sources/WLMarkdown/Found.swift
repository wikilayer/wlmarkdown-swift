/// One dialect construct found in a document.
public struct Found: Equatable, Sendable, Codable {
  /// The construct kind: `callout`, `map`, `unreadable`, or `link`.
  public let kind: String
  /// The callout class, or an empty string for another kind.
  public let `class`: String
  /// The latitude exactly as written, or an empty string for another kind.
  public let lat: String
  /// The longitude exactly as written, or an empty string for another kind.
  public let lng: String
  /// The map caption, or an empty string for another kind.
  public let caption: String
  /// The recognised node-reference scheme, or an empty string when none applies.
  public let scheme: String
  /// The link destination exactly as written, or an empty string for another kind.
  public let destination: String
  /// Reader-visible or source-preserving text carried by the construct.
  public let text: String

  /// Creates a construct value, leaving fields irrelevant to its kind empty.
  public init(
    kind: String,
    class calloutClass: String = "",
    lat: String = "",
    lng: String = "",
    caption: String = "",
    scheme: String = "",
    destination: String = "",
    text: String = ""
  ) {
    self.kind = kind
    self.class = calloutClass
    self.lat = lat
    self.lng = lng
    self.caption = caption
    self.scheme = scheme
    self.destination = destination
    self.text = text
  }

  /// Decodes a construct while treating fields absent from another port as empty.
  public init(from decoder: any Decoder) throws {
    let held = try decoder.container(keyedBy: CodingKeys.self)
    kind = try held.decode(String.self, forKey: .kind)
    `class` = try held.decodeIfPresent(String.self, forKey: .class) ?? ""
    lat = try held.decodeIfPresent(String.self, forKey: .lat) ?? ""
    lng = try held.decodeIfPresent(String.self, forKey: .lng) ?? ""
    caption = try held.decodeIfPresent(String.self, forKey: .caption) ?? ""
    scheme = try held.decodeIfPresent(String.self, forKey: .scheme) ?? ""
    destination = try held.decodeIfPresent(String.self, forKey: .destination) ?? ""
    text = try held.decodeIfPresent(String.self, forKey: .text) ?? ""
  }
}
