// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OktaIdx",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v7),
        .macOS(.v10_11)
    ],
    products: [
        .library(name: "OktaIdx", targets: [ "OktaIdx" ])
    ],
    dependencies: [
        .package(name: "AuthFoundation",
                 url: "https://github.com/okta/okta-mobile-swift",
                 branch: "master")
    ],
    targets: [
        .target(name: "OktaIdx",
                dependencies: [ "AuthFoundation" ]),
        .target(name: "TestCommon",
                dependencies: [ "OktaIdx" ],
                path: "Tests/TestCommon",
                resources: [ .copy("SampleResponses") ]),
        .testTarget(name: "OktaIdxTests",
                    dependencies: [ "OktaIdx", "TestCommon" ])
    ],
    swiftLanguageVersions: [.v5]
)
