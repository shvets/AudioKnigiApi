// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "AudioKnigiApi",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16)
  ],
  products: [
    .library(name: "AudioKnigiApi", targets: ["AudioKnigiApi"])
  ],
  dependencies: [
    .package(name: "SimpleHttpClient", path: "../SimpleHttpClient"),
    //.package(url: "https://github.com/shvets/SimpleHttpClient", from: "1.0.8"),
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
      exclude: [
        "cryptojs/components/aes.js"
      ]
//      resources: [
//        .process("cryptojs/components/aes.js")
//      ]
    ),
    .testTarget(
      name: "AudioKnigiApiTests",
      dependencies: [
        "AudioKnigiApi"
      ]
    )
  ]
)
