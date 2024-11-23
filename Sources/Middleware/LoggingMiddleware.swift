//
//  LoggingMiddleware.swift
//  MFNetwork
//
//  Created by Dmitrii Voronin on 20.10.2024.
//

import Foundation

@available(iOS 13.0.0, *)
public struct LoggingMiddleware: APIClient.Middleware {
    
    private var logger: Logging
    
    public init(logger: any Logging) {
        self.logger = logger
    }
    
    public func intercept(_ request: URLRequest) async throws -> (URLRequest) {
        // TODO: - use customdescription
        print(request.customDescription)
        logger.log(message: request.customDescription)
        return request
    }
}

// MARK: - Logging
public protocol Logging {
    func log(message: String)
}

public struct Logger: Logging {
    public func log(message: String) {
        print(#function, message)
    }
    
    public init() {}
}
