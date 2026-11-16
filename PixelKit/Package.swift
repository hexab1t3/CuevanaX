// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PixelKit",
    platforms: [.iOS("18.0")],
    products: [
        .library(name: "PixelKit", targets: ["PixelKit"])
    ],
    targets: [
        .target(name: "PixelKit")
    ]
)
