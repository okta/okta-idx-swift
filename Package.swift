// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OktaIdx",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v10)
    ],
    products: [
        .library(name: "OktaIdx",
                 targets: [ "OktaIdx" ])
    ],
    dependencies: [
        .package(name: "AuthFoundation",
                 url: "https://github.com/okta/okta-mobile-swift",
                 branch: "man-OKTA-484828-IDXUpdates")
    ],
    targets: [
        .target(name: "OktaIdx",
                dependencies: [ "AuthFoundation" ],
                exclude: ["Info.plist"]),
        .target(name: "TestCommon",
                dependencies: [ "OktaIdx" ],
                path: "Tests/TestCommon",
                resources: [ .copy("SampleResponses") ]),
        .testTarget(name: "OktaIdxTests",
                    dependencies: [ "OktaIdx", "TestCommon" ],
                    exclude: ["Info.plist"])
    ]
)
