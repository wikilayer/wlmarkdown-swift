// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WLMarkdown",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "WLMarkdown", targets: ["WLMarkdown"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.8.0"),
        .package(url: "https://github.com/botforge-pro/swift-embed", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "WLMarkdown",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "SwiftEmbed", package: "swift-embed")
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "WLMarkdownTests",
            dependencies: [
                "WLMarkdown",
                .product(name: "SwiftEmbed", package: "swift-embed")
            ],
            resources: [.process("Resources")])
    ]
)
