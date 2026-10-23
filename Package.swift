// swift-tools-version:5.9
// The calculation engine as a standalone package, so it can be unit-tested with
// `swift test` (locally and in CI). The iOS app compiles the same sources directly.
import PackageDescription

let package = Package(
    name: "CompounderCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CompounderCore", targets: ["CompounderCore"])
    ],
    targets: [
        .target(name: "CompounderCore", path: "Compounder/Core"),
        .testTarget(
            name: "CompounderCoreTests",
            dependencies: ["CompounderCore"],
            path: "Tests/CompounderCoreTests"
        )
    ]
)
