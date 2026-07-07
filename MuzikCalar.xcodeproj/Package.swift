// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MuzikCalar",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "MuzikCalar", targets: ["MuzikCalar"])
    ],
    targets: [
        .executableTarget(
            name: "MuzikCalar",
            path: ".",
            exclude: [".github"],
            sources: ["App", "Models", "Services", "ViewModels", "Views"],
            resources: [
                .process("MuzikCalar/Info.plist")
            ]
        )
    ]
)
