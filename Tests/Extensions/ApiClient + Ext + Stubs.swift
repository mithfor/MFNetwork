//
//  ApiClient + Ext + Stubs.swift
//  MFNetworkTests
//
//  Created by Dmitrii Voronin on 24.10.2024.
//

import Foundation
@testable import MFNetwork

extension APIClient {
    func stub(error: Error, code: Int, endpoint: String? = nil) -> Self {
        MockedURLProtocol.stub(error: error, code: code, endpoint: endpoint ?? MockedURLProtocol.endpoint)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    func stub(data: Data, code: Int, endpoint: String? = nil) -> Self {
        MockedURLProtocol.stub(data: data, code: code, endpoint: endpoint ?? MockedURLProtocol.endpoint)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    func stub(json: String, code: Int, endpoint: String? = nil) -> Self {
        MockedURLProtocol.stub(json: json, code: code, endpoint: endpoint ?? MockedURLProtocol.endpoint)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    func reset() -> Self {
        MockedURLProtocol.reset()
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
}


