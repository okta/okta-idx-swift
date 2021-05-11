// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OktaIdx",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v10)
    ],
    products: [
        .library(name: "OktaIdx",
                 targets: [ "OktaIdx" ]),
        .library(name: "OktaIdxAuth",
                 targets: [ "OktaIdxAuth" ])
    ],
    targets: [
        .target(name: "OktaIdx",
                exclude: ["Info.plist"]),
        .target(name: "OktaIdxAuth",
                dependencies: [ "OktaIdx" ],
                exclude: ["Info.plist"]),
        .target(name: "TestCommon_OktaIdx",
                dependencies: [ "OktaIdx" ],
                path: "Tests/TestCommon_OktaIdx",
                resources: [ .copy("Resources") ]),
        .target(name: "TestCommon_OktaIdxAuth",
                dependencies: [ "OktaIdxAuth" ],
                path: "Tests/TestCommon_OktaIdxAuth"),
        .testTarget(name: "OktaIdxTests",
                    dependencies: [ "OktaIdx", "TestCommon_OktaIdx" ],
                    exclude: ["Info.plist"]),
        .testTarget(name: "OktaIdxAuthTests",
                    dependencies: [ "OktaIdxAuth", "TestCommon_OktaIdx", "TestCommon_OktaIdxAuth" ],
                    exclude: ["Info.plist"])
    ]
)
