import Foundation
import Testing
@testable import WLMarkdown

struct CorpusIsCurrentTests {
    static let copiedFromTheLeadingPort = [
        "Sources/WLMarkdown/Resources/rules.yaml",
        "Tests/WLMarkdownTests/Resources/dialect.yaml"
    ]

    @Test(
        "every file copied from the leading port is still the one it holds",
        arguments: copiedFromTheLeadingPort
    )
    func stillTheirs(_ path: String) async throws {
        let here = Self.packageRoot.appending(path: path)
        let held = try Data(contentsOf: here)
        let theirs = try await leading(here.lastPathComponent)
        #expect(held == theirs, Comment(rawValue:
            "\(path) is not the file the leading port holds, so this port answers an older "
                + "dialect than the others; run make sync-corpus"))
    }

    @Test func theListNamesEveryCopySyncCorpusMakes() {
        #expect(
            Self.copiedFromTheLeadingPort.count == 2,
            "sync-corpus copies the rules to the library and the cases to the tests"
        )
    }

    private static let leadingPort = "https://raw.githubusercontent.com/wikilayer/wlmarkdown/main/corpus/"

    private static let packageRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

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
