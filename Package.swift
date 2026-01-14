// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DevTools",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DevTools", targets: ["DevTools"])
    ],
    targets: [
        .executableTarget(
            name: "DevTools",
            path: "Sources"
        )
    ]
)
