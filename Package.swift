// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package (
   name: "X3D",
   platforms: [
      .macOS (.v10_15)
   ],
   products: [
      // Products define the executables and libraries a package produces, and make them visible to other packages.
      .library (
         name: "X3D",
         targets: ["X3D"]),
   ],
   dependencies: [
      // Dependencies declare other packages that this package depends on.
      // .package(url: /* package url */, from: "1.0.0"),
      .package (name: "swift-atomics",  url: "https://github.com/apple/swift-atomics.git",         from: ("0.0.1")),
      .package (name: "CoreTextSwift",  url: "https://github.com/krzyzanowskim/CoreTextSwift.git", .branch ("master")),
      .package (name: "Gzip",           url: "https://github.com/1024jp/GzipSwift.git",            from: "5.1.1"),
      .package (name: "LibTessSwift",   url: "https://github.com/LuizZak/LibTessSwift.git",        from: "0.8.2"),
      .package (name: "swift-numerics", url: "https://github.com/apple/swift-numerics.git",        from: "0.0.8"),
      .package (name: "SwiftImage",     url: "https://github.com/koher/swift-image.git",           from: "0.7.1")
   ],
   targets: [
      // Targets are the basic building blocks of a package. A target can define a module or a test suite.
      // Targets can depend on other targets in this package, and on products in packages this package depends on.
      .target (
         name: "_X3D"),
      .target (
         name: "X3D",
         dependencies: [
            "_X3D",
            .product (name: "Atomics",       package: "swift-atomics"),
            .product (name: "CoreTextSwift", package: "CoreTextSwift"),
            .product (name: "Gzip",          package: "Gzip"),
            .product (name: "LibTessSwift",  package: "LibTessSwift"),
            .product (name: "Numerics",      package: "swift-numerics"),
            .product (name: "SwiftImage",    package: "SwiftImage")
         ],
         exclude: [
         ],
         resources: [
            .copy ("Fonts/"),
            .process ("Shaders/ShaderDefinitions.h")
         ]),
      .testTarget (
         name: "X3DTests",
         dependencies: ["X3D"],
         resources: [
            .process ("data/beethoven-no-normals.x3dvz"),
            .process ("data/forklift3.wrz")
         ]),
    ]
)
