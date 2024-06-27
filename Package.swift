// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "AudioKnigiApi",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .tvOS(.v17)
  ],
  products: [
    .library(name: "AudioKnigiApi", targets: ["AudioKnigiApi"])
  ],
  dependencies: [
    //.package(name: "SimpleHttpClient", path: "../SimpleHttpClient"),
    .package(url: "https://github.com/shvets/SimpleHttpClient", from: "1.0.10"),
    .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.3.2"),
    .package(url: "https://github.com/JohnSundell/Codextended", from: "0.3.0")
  ],
  targets: [
    .target(
      name: "AudioKnigiApi",
      dependencies: [
        "SimpleHttpClient",
        "SwiftSoup",
        "Codextended"
      ],
//      exclude: [
//        "cryptojs/components/aes.js"
//      ],
      resources: [
        .process("cryptojs/components/aes.js"),
        .process("Resources"),
//        .process("Resources/authors-in-groups.json"),
//        .process("Resources/performers-in-groups.json")
      ]
    ),
    .testTarget(
      name: "AudioKnigiApiTests",
      dependencies: [
        "AudioKnigiApi"
      ]
    )
  ]
)
