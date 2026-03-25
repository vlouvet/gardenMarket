// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "GardenMarket",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    targets: [
        .executableTarget(
            name: "GardenMarket",
            path: "GardenMarket",
            exclude: ["Resources/Info.plist"]
        ),
    ]
)
