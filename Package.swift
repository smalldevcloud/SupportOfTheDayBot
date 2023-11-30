// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SupportOfTheDayBot",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.83.1"),
        .package(url: "https://github.com/nerzh/telegram-vapor-bot", .upToNextMajor(from: "2.1.0")),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "TelegramVaporBot", package: "telegram-vapor-bot"),
            ]
        )
    ]
)
