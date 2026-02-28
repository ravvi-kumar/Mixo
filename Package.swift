// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Mixo",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Mixo", targets: ["Mixo"])
    ],
    targets: [
        .executableTarget(
            name: "Mixo",
            path: "Sources/Mixo"
        ),
        .testTarget(
            name: "MixoTests",
            dependencies: ["Mixo"],
            path: "Tests/MixoTests"
        )
    ]
)
