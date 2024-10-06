//
//  Resources.swift
//  Core
//
//  Created by Ahmed Chebbi on 06/10/2024.
//

import Foundation

public struct Resources<T:Codable, U: Any> {
    let url:URL
    var headers: [String: String] = [:]
    let method: HTTPMethod<U>
    
    public init(url: URL, headers: [String : String] = [:], method: HTTPMethod<U>) {
        self.url = url
        self.headers = headers
        self.method = method
    }
}

public enum HTTPMethod<T: Any> {
    case GET([URLQueryItem])
    case POST(body: T?)
    case PUT(body: T?)

    var name: String {
        switch self {
        case .GET: return "GET"
        case .POST: return "POST"
        case .PUT: return "PUT"
        }
    }
}

public struct EmptyResponse: Codable {
    public init() {}
}
