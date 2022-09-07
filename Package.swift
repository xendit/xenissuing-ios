// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Xenissuing",
    // Set minimum deployment target to macOS 10.15 and iOS 14.
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Xenissuing",
            targets: ["Xenissuing"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMajor(from: "1.5.1")),
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Xenissuing",
            dependencies: [
                "CryptoSwift",
                .product(name: "Crypto", package: "swift-crypto")
            ]
        ),
        .testTarget(
            name: "XenissuingTests",
            dependencies: ["Xenissuing"]
        )
    ]
)
