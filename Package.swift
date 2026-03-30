// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TheLocalExplorer",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TheLocalExplorer", targets: ["TheLocalExplorer"])
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.54.0"),
    ],
    targets: [
        .target(
            name: "TheLocalExplorer",
            path: "TheLocalExplorer"
        )
    ]
)
