// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SimpleMDM-Swift",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "SimpleMDM",targets: ["SimpleMDM"])
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.8.0"))
    ],
    targets: [
        .target(name: "SimpleMDM", dependencies: ["PromiseKit"], path: "Sources"),
        .testTarget(name: "SimpleMDM-Tests", dependencies: ["SimpleMDM"], path: "Tests")
    ],
    swiftLanguageVersions: [.v5]
)
