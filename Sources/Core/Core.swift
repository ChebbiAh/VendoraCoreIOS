// The Swift Programming Language
// https://docs.swift.org/swift-book

@preconcurrency import Swinject

public struct Core {
    public static let container = Container()

    public static func register() {
        // Singleton
        Core.container.register(Network.self) { _ in NetworkAPI() }.inObjectScope(.container)
    }
    
}
