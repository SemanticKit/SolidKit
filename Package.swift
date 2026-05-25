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
        .package(path: "../WebIDKit"),
        .package(path: "../URIKit"),
        .package(path: "../HttpSigKit"),
        .package(path: "../PolicyKit"),
        .package(path: "../AuditKit")
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
