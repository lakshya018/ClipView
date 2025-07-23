// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ClipViewApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ClipViewApp", targets: ["ClipViewApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ClipViewApp",
            dependencies: [],
            path: "Sources/ClipViewApp"
        )
    ]
)
