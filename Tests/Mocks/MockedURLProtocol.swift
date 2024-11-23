//
//  Stubbing.swift
//  MFNetworkTests
//
//  Created by Dmitrii Voronin on 24.10.2024.
//

import Foundation
@testable import MFNetwork

struct ExpectedReponse {
    let statusCode: Int
    let content: Result<Data, Error>
    
    init(data: Data, statusCode: Int) {
        self.statusCode = statusCode
        self.content = .success(data)
    }
    
    init(error: Error, statusCode: Int) {
        self.statusCode = statusCode
        self.content = .failure(error)
    }
}

class MockedURLProtocol: URLProtocol {
    static let endpoint = "<mocked-endpoint>"
    private static var stubs: [String: [ExpectedReponse]] = [:]
    
    private static func stub(response: ExpectedReponse, for endpont: String) {
        if let responses = stubs[endpont] {
            stubs[endpont] = responses + [response]
        } else {
            stubs[endpont] = [response]
        }
    }
    
    static func reset() {
        stubs = [:]
    }
    
    static func stub(data: Data, code: Int, endpoint: String = endpoint) {
        stub(response: ExpectedReponse(data: data,
                                       statusCode: code),
             for: endpoint)
    }
    
    static func stub(error: Error, code: Int, endpoint: String = endpoint) {
        stub(response: ExpectedReponse(error: error,
                                       statusCode: code),
             for: endpoint)
    }
    
    static func stub(json: String, code: Int, endpoint: String = endpoint) {
        stub(response: ExpectedReponse(data: json.data(using: .utf8)!,
                                       statusCode: code),
             for: endpoint)
    }
    
    static func stub(contentsOfFile url: URL, code: Int, endpoint: String = endpoint) {
        let content = try! String(contentsOf: url, encoding: .utf8)
        stub(json: content, code: code, endpoint: endpoint)
    }
    
    static func response(for request: URLRequest) -> ExpectedReponse? {
        if let url = request.url?.absoluteString {
            for endpoint in stubs {
                if url.hasSuffix(endpoint.key) {
                    return consume(endpoint.key)
                }
            }
        }
        return consume(endpoint)
    }
    
    static func consume(_ endpoint: String) -> ExpectedReponse? {
        let queue = stubs[endpoint]
        let response = queue?.first
        stubs[endpoint] = Array(queue?.dropFirst() ?? [])
        return response
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = MockedURLProtocol.response(for: request) else { fatalError("No response stubbed for request \(request)")
        }
        
        let header = request.allHTTPHeaderFields
        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: stub.statusCode,
                                       httpVersion: nil,
                                       headerFields: header)!
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        switch stub.content {
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        case .success(let data):
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() { }
}



//extension URLSessionConfiguration {
//    static var testing: URLSessionConfiguration {
//        let configuration = URLSessionConfiguration.default
//        configuration.protocolClasses = [MockedURLProtocol.self] as [AnyClass]
//        return configuration
//    }
//}

