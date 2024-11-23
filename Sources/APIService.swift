//
//  APIService.swift
//  MFNetwork
//
//  Created by Dmitrii Voronin on 17.10.2024.
//

import Foundation

@available(iOS 13.0.0, *)
open class APIService {
    private(set) var _apiClient: APIClient?
    
    public init(apiClient: APIClient?) {
        self._apiClient = apiClient
    }
    
    public var apiClient: APIClient? {
        get {
            return self._apiClient
        }
    }
}
