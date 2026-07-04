// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sqlite3_simple",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "sqlite3-simple", targets: ["sqlite3_simple"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "sqlite3_simple",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "CSimple",
                "sqlite3_simple_anchor"
            ]
        ),
        .binaryTarget(
            name: "CSimple",
            path: "CSimple.xcframework"
        ),
        .target(
            name: "sqlite3_simple_anchor",
            dependencies: ["CSimple"]
        )
    ]
)
