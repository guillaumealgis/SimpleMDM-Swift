// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SimpleMDM-Swift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "SimpleMDM", targets: ["SimpleMDM"])
    ],
    targets: [
        .target(name: "SimpleMDM", path: "Sources", exclude: ["Templates"]),
        .testTarget(name: "SimpleMDM-Tests", dependencies: ["SimpleMDM"], path: "Tests", resources: [.process("Fixtures")])
    ],
    swiftLanguageVersions: [.v5]
)
