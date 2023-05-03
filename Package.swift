// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var package = Package(
    name: "OktaIdx",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v7),
        .macOS(.v10_11)
    ],
    products: [
        .library(name: "OktaIdx", targets: ["OktaIdx"]),
        .library(name: "WebAuthN", targets: ["WebAuthN"])
    ],
    dependencies: [
        .package(name: "AuthFoundation",
                 url: "https://github.com/okta/okta-mobile-swift",
                 from: "1.2.0")
    ],
    targets: [
        .target(name: "OktaIdx",
                dependencies: ["AuthFoundation", "WebAuthN"]),
        .target(name: "WebAuthN"),
        .target(name: "TestCommon",
                path: "Tests/TestCommon"),
        .testTarget(name: "OktaIdxTests",
                    dependencies: ["OktaIdx", "TestCommon"],
                resources: [.copy("SampleResponses")]),
        .testTarget(name: "WebAuthNTests",
                    dependencies: ["WebAuthN", "TestCommon"],
                    resources: [.copy("SampleResponses")])
    ],
    swiftLanguageVersions: [.v5]
)

#if swift(>=5.6)
    package.dependencies.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"))
#endif

