// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "NurseFlowPersonalCore", products: [.library(name: "NurseFlowCore", targets: ["NurseFlowCore"])], targets: [
    .target(name: "NurseFlowCore", path: "NurseFlowPersonal/Domain"),
    .testTarget(name: "NurseFlowCoreTests", dependencies: ["NurseFlowCore"], path: "Tests")
])
