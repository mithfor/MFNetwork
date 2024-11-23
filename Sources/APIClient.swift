//
//  APIClient.swift
//  MFNetwork
//
//  Created by Dmitrii Voronin on 17.10.2024.
//

import Foundation

public protocol DecodableType: Decodable {}

@available(iOS 13.0.0, *)
public struct APIClient {
    private var baseURL: URL
    private var urlSession: URLSession
    private(set) var middlewares: [any APIClient.Middleware]
    
    public init(baseURL: URL,
                     middlewares: [APIClient.Middleware] = [],
                     urlSession: URLSession = URLSession.shared) {

        self.baseURL = baseURL
        self.middlewares = middlewares
        self.urlSession = urlSession
    }
}

@available(iOS 13.0.0, *)
public extension APIClient {
    func sendRequest(_ apiSpec: APISpec) async throws -> DecodableType {
        guard let url = URL(string: baseURL.absoluteString + apiSpec.endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: TimeInterval(floatLiteral: 30.0))
        
        request.httpMethod = apiSpec.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = apiSpec.body
        
        // MARK: - Middlewares
        var updateRequest = request
        for middleware in self.middlewares {
            let tempRequest = updateRequest
            updateRequest = try await wrapCatchingErrors(work: {
                try await middleware.intercept(tempRequest)
            })
        }
        
        var responseData: Data? = nil
        do {
            let (data, response) = try await urlSession.data(for: request)
            try handleResponse(data: data, response: response)
            responseData = data
        } catch {
            throw error
        }
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(
                apiSpec.returnType,
                from: responseData!
            )
            return decodedData
        } catch let error as DecodingError {
            throw error
        } catch {
            throw NetworkError.dataConversionFailure
        }
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
    
    private func wrapCatchingErrors<R>(work: () async throws -> R) async throws -> R {
        do {
            return try await work()
        } catch {
            throw error
        }
    }
    
    func copy(session newSession: URLSession) -> Self {
        var apiClientCopy = self
        apiClientCopy.urlSession = newSession
        return apiClientCopy
    }
}

@available(iOS 13.0.0, *)
public extension APIClient {
    protocol APISpec {
        var endpoint: String { get }
        var method: HttpMethod { get }
        var returnType: DecodableType.Type { get }
        var body: Data? { get }
    }
    
    enum HttpMethod: String, CaseIterable {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
        case put = "PUT"
        case head = "HEAD"
        case options = "OPTIONS"
    }
    
    enum NetworkError: Error {
        case invalidURL
        case dataConversionFailure
        case invalidResponse
        case requestFailed(_ statusCode: Int)
    }
}

// MARK: - Middleware

@available(iOS 13.0.0, *)
public extension APIClient {
    @available(iOS 13.0.0, *)
    protocol Middleware {
        func intercept(_ request: URLRequest) async throws -> (URLRequest)
    }
}





