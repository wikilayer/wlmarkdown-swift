import Foundation
import Testing
@testable import WLMarkdown

struct CorpusIsCurrentTests {
    static let copiedFromTheLeadingPort = ["rules.yaml", "dialect.yaml"]

    @Test(
        "every file copied from the leading port is still the one it holds",
        arguments: copiedFromTheLeadingPort
    )
    func stillTheirs(_ name: String) async throws {
        let held = try held(name)
        let theirs = try await leading(name)
        #expect(held == theirs, Comment(rawValue:
            "\(name) here is not the one the leading port holds, so this port answers an older "
                + "dialect than the others; run make sync-corpus"))
    }

    @Test func theListIsNotEmpty() {
        #expect(Self.copiedFromTheLeadingPort.count > 1, "a list this short cannot have been read")
    }

    private static let leadingPort = "https://raw.githubusercontent.com/wikilayer/wlmarkdown/main/corpus/"

    private func held(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: nil) else {
            throw Absent(what: "\(name) is not in the test bundle; run make sync-corpus")
        }
        return try Data(contentsOf: url)
    }

    private func leading(_ name: String) async throws -> Data {
        guard let url = URL(string: Self.leadingPort + name) else {
            throw Absent(what: "the address of the leading port does not parse")
        }
        let (data, answer) = try await URLSession.shared.data(from: url)
        guard let http = answer as? HTTPURLResponse, http.statusCode == 200 else {
            throw Absent(what: "the leading port did not hand back \(name), so this test proves nothing")
        }
        return data
    }

    private struct Absent: Error, CustomStringConvertible {
        let what: String
        var description: String { what }
    }
}
