//
//  AuthorizationMiddleWare.swift
//  MFNetwork
//
//  Created by Dmitrii Voronin on 20.10.2024.
//

import Foundation

@available(iOS 13.0.0, *)
public class AuthorizationMiddleWare: APIClient.Middleware {
    private var token: String?
    
    public init(token: String? = nil) {
        self.token = token
    }
    
    public func intercept(_ request: URLRequest) async throws -> (URLRequest) {
        var requestCopy = request
        requestCopy.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        return requestCopy
    }
}
