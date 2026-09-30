// swift-tools-version: 6.1
// iStats — free, local menu bar system monitor for the iSuite bundle.
import PackageDescription

let package = Package(
    name: "IStats",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "IStats",
            path: "Sources/IStats"
        )
    ],
    swiftLanguageModes: [.v5]
)
