//
//  EndPointAPI.swift
//  Core
//
//  Created by Ahmed Chebbi on 06/10/2024.
//

import Foundation

public protocol NetworkSession {
    func data(request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    public func data(request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await self.data(for: request)
        return (data, response)
    }
}

public protocol Network {
    func downloadApiData<T: Codable, U: Codable>(_ resource: Resources<T, U>) async throws  -> T
}

public class NetworkAPI: Network {
    public init() {}

    public func downloadApiData<T: Codable, U: Codable>(_ resource: Resources<T, U>) async throws
        -> T
    {
        do {

            //-----------Set Up URLRequest---------------
            var request = URLRequest(url: resource.url)

            @Inject(name: "token")
            var token: String?

            request.allHTTPHeaderFields = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token ?? "")",
            ]
            request.httpMethod = resource.method.name
            var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: true)

            //--------- Configure HTTP Method--------------
            switch resource.method {
            case .GET(let queryItems): components?.queryItems = queryItems
            case .POST(let body):
                if body is String {
                    request.httpBody = Data(((body as? String) ?? "").utf8)

                } else {
                    request.httpBody = requestBodyFrom(params: body)
                }
                break
            case .PUT(let body):
                request.httpBody = requestBodyFrom(params: body)
            }

            //----------- Configure API URL--------------
            guard let url = components?.url else {
                throw NetworkErrorInterceptor.badUrl(components?.url?.absoluteString)
            }
            request.url = url

            //----------- Set Up URLSessionConfiguration and custom header-----------
            let configuraton = URLSessionConfiguration.default
            configuraton.httpAdditionalHeaders = resource.headers
            Logger.logInfo(resource.headers.debugDescription)
            Logger.logInfo(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")
            //--------- Start Downloading data--------------
            let session = URLSession(configuration: configuraton)
            let (data, response) = try await session.data(request: request)
            Logger.logInfo(response.debugDescription)
            Logger.logInfo(String(data: data, encoding: .utf8) ?? "")
            //--------- Check HTTP Error Or Not--------------
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkErrorInterceptor.unknownError
            }

            //----------Check Resonse is Error-----------------------
            if httpResponse.statusCode < 200 || httpResponse.statusCode > 300 {
                throw NetworkErrorInterceptor.unknownError
            }

            //----------When Response is Success----------------
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                return result
            } catch {
                throw NetworkErrorInterceptor.decodingError
            }

        } catch {
            guard let urlError = error as? URLError else {
                throw NetworkErrorInterceptor.unknownError
            }
            if urlError.code == .notConnectedToInternet {
                throw NetworkErrorInterceptor.noInternet
            } else if urlError.code == .timedOut {
                throw NetworkErrorInterceptor.connectionTimeout
            } else {
                throw NetworkErrorInterceptor.unknownError
            }
        }

        func requestBodyFrom(params: U?) -> Data? {
            guard let params = params else { return nil }
            let encoder = JSONEncoder()
            do {
                let httpBody = try encoder.encode(params)
                return httpBody
            } catch {
                Logger.logInfo("Error encoding params: \(error)")
                return nil
            }
        }
    }

}

public enum NetworkErrorInterceptor: Error, Equatable {
    case badUrl(String?)
    case decodingError
    case noInternet
    case connectionTimeout
    case unknownError
    case noData

    public var message: String {
        switch self {
        case .badUrl(let url): return "Invalid URL: \(String(describing: url))"
        case .decodingError: return "Data missmatch. Please try again!"
        case .unknownError: return "Unknown error occurred. Please try again"
        case .noInternet: return "No internet connection. Please check your internet connection"
        case .connectionTimeout: return "Connection timeout. Please try again"
        case .noData: return "No data found. Please try again"
        }
    }
}
