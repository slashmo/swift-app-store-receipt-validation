// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-app-store-receipt-validation",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .watchOS(.v3),
        .tvOS(.v10),
    ],
    products: [
        .library(
            name: "AppStoreReceiptValidation",
            targets: ["AppStoreReceiptValidation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.10.0")),
        .package(url: "https://github.com/swift-server/async-http-client.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "AppStoreReceiptValidation", dependencies: [
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOFoundationCompat", package: "swift-nio"),
        ]),
        .testTarget(name: "AppStoreReceiptValidationTests", dependencies: [
            .byName(name: "AppStoreReceiptValidation"),
        ]),
    ]
)
