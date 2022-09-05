// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "Xenissuing",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Xenissuing",
            targets: ["Xenissuing"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .exact("1.4.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Xenissuing",
            dependencies: [],
            exclude: ["README.md"]
        ),
        .testTarget(
            name: "XenissuingTests",
            dependencies: ["Xenissuing"],
            exclude: ["README.md"]
        ),
    ]
)
