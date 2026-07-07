// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MuzikCalar",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "MuzikCalar", targets: ["MuzikCalar"]),
    ],
    targets: [
        .target(
            name: "MuzikCalar",
            path: "." // Tüm klasörleri (App, Views vb.) otomatik tarar
        )
    ]
)
