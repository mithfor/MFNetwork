//
//  URLSessionConfiguration + Ext.swift
//  MFNetwork
//
//  Created by Dmitrii Voronin on 25.10.2024.
//

import Foundation

extension URLSessionConfiguration {
    static var testing: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockedURLProtocol.self] as [AnyClass]
        return configuration
    }
}
