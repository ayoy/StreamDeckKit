// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StreamDeckKit",
    platforms: [.macOS("12.0")],
    products: [
        .library(name: "StreamDeckKit", targets: ["StreamDeckKit"])
    ],
    targets: [
        .target(
            name: "StreamDeckKit",
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend",
                    "-enable-experimental-concurrency"
                ])
            ]
        ),
        .testTarget(
            name: "StreamDeckKitTests",
            dependencies: ["StreamDeckKit"]
        )
    ]
)
