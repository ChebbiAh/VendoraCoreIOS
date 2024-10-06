//
//  Inject.swift
//  Core
//
//  Created by Ahmed Chebbi on 06/10/2024.
//

import Foundation

@propertyWrapper
public struct Inject<T> {
    private var value: T?

    public var wrappedValue: T {
        mutating get {
            Core.container.resolve(T.self, name: name)!
        }
        set {
            value = newValue
        }
    }
    
    private var name: String?

    public init() {
        self.name = nil
    }

    public init(name: String) {
        self.name = name
    }
}
