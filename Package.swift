// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppleMusic",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "AppleMusic",
            targets: ["AppleMusic"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppleMusic",
            dependencies: [],
            path: "AppleMusic",
            exclude: [
                "Resources/Info.plist",
                "Resources/AppleMusic.entitlements"
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        )
    ]
)
