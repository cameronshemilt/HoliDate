// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "HoliDate",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "HoliDate", targets: ["HoliDate"])
    ],
    targets: [
        .target(
            name: "HoliDate",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "HoliDateTests",
            dependencies: ["HoliDate"]
        )
    ]
)
