//
//  URLRequest + Ext.swift
//  MFNetwork
//
//  Created by Dmitrii Voronin on 20.10.2024.
//

import Foundation

extension URLRequest {
    public var customDescription: String {
        var printableDiscription = ""
        if let method = self.httpMethod {
            printableDiscription += method
        }
        
        if let urlString = self.url?.absoluteString {
            printableDiscription += urlString
        }
        
        if let headers = self.allHTTPHeaderFields, !headers.isEmpty {
            printableDiscription += "\\nHeaders: \(headers)"
        }
        
        if let bodyData = self.httpBody,
           let body = String(data: bodyData, encoding: .utf8) {
            printableDiscription += "\\nBody: \(body)"
        }
        
        return printableDiscription.replacingOccurrences(of: "\\n", with: "\n")
    }
}
