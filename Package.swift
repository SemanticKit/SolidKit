// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SolidKit",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "SolidKit",
            targets: ["SolidKit"]
        )
    ],
    dependencies: [
        .package(path: "https://github.com/SemanticKit/WebIDKit.git"),
        .package(path: "https://github.com/SemanticKit/URIKit.git"),
        .package(path: "https://github.com/SemanticKit/HttpSigKit.git"),
        .package(path: "https://github.com/SemanticKit/PolicyKit.git"),
        .package(path: "https://github.com/SemanticKit/AuditKit.git")
    ],
    targets: [
        .target(
            name: "SolidKit",
            dependencies: [
                "WebIDKit",
                "URIKit",
                "HttpSigKit",
                "PolicyKit",
                "AuditKit"
            ]
        ),
        .testTarget(
            name: "SolidKitTests",
            dependencies: ["SolidKit"]
        )
    ]
)
