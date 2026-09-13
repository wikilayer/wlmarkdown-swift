public struct Found: Equatable, Sendable, Codable {
    public let kind: String
    public let `class`: String
    public let lat: String
    public let lng: String
    public let caption: String
    public let scheme: String
    public let destination: String
    public let text: String

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
