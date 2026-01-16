// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AnalyticsKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]
        ),
    ],
    targets: [
        .target(
            name: "AnalyticsKit",
            dependencies: []
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            dependencies: ["AnalyticsKit"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
