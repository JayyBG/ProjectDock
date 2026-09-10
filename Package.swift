// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ProjectDock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ProjectDock", targets: ["ProjectDock"])
    ],
    targets: [
        .executableTarget(
            name: "ProjectDock",
            path: "Sources/ProjectDock"
        )
    ]
)
