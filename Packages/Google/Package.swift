// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Google",
    platforms: [
        .iOS(.v26), .tvOS(.v26), .macOS(.v15), .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Google",
            targets: ["Google"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.3.0"
        )
    ],
    targets: [
        .target(
            name: "Google",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAI", package: "firebase-ios-sdk")
            ],
            resources: [
                .copy("Resources/GoogleService-Info.plist")
            ]
        ),
        .testTarget(
            name: "GoogleTests",
            dependencies: ["Google"]
        ),
    ]
)
