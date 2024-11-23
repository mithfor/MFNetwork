//
//  APIClientTests.swift
//  MFNetworkTests
//
//  Created by Dmitrii Voronin on 25.10.2024.
//

import Foundation
import XCTest
@testable import MFNetwork

struct MockDecodableType: DecodableType {
    
}

enum MockApiSpec: APIClient.APISpec {
    
    case simpleRequest(todo: Int)
    
    var endpoint: String {
        switch self {
        case .simpleRequest(todo: let todoId):
            return "/todo/\(todoId)"
        }
    }
    
    var method: MFNetwork.APIClient.HttpMethod {
        switch self {
        case .simpleRequest(todo: _):
            return .get
        }
    }
    
    var returnType: any MFNetwork.DecodableType.Type {
        switch self {
        case .simpleRequest(todo: _):
            return MockDecodableType.self
        }
    }
    
    var body: Data? {
        switch self {
        case .simpleRequest(todo: _):
            return nil
        }
    }
    
    
}

class APIClientTests: XCTestCase {
    let baseURL = URL(string: "api.example.com")!
    lazy var sut = APIClient(baseURL: baseURL)
    
    override func tearDownWithError() throws {
        sut = sut.reset()
    }
    
    func test_sendRequest_ReturnsCorrectSimpleResponseType_WhenSimpleGetRequest() async throws {
        
        let todoId: Int = 156
        let singleTodoResponse = """
           {
            "userId": 1,
        "id": 156,
        "title": "buy all things",
        "completed": false
        } 
        """
        
        sut = APIClient(baseURL: baseURL)
            .stub(json: singleTodoResponse,
                  code: 200,
                  endpoint: "/todo/\(todoId)")
        
        
        let apiSpec: MockApiSpec = .simpleRequest(todo: todoId)
        let responseModel = try await sut.sendRequest(apiSpec)
        
        XCTAssert(type(of: responseModel) == MockDecodableType.self)
    }
    
    func test_sendRequest_failWith404_WhenSimpleGetRequest() async throws {
        let todoId = 156
        let emptyTodoResponse = """
        """
        
        sut = APIClient(baseURL: baseURL)
            .stub(json: emptyTodoResponse,
                  code: 404,
                  endpoint: "/todo/\(todoId)")
        
        let apiSpec: MockApiSpec = .simpleRequest(todo: todoId)
        
        do {
            let _ = try await sut.sendRequest(apiSpec)
            XCTFail("Expected an error to be thrown, but the call completed successfully")
        } catch {
            XCTAssertTrue(error is APIClient.NetworkError,
                          "The error is not a type of APIClient.NetworkError")
            if let apiError = error as? APIClient.NetworkError {
                switch apiError {
                case .requestFailed(let code):
                    XCTAssertEqual(code, 404)
                    break
                default:
                    XCTFail("Expected a requestFailed error, reseived \(apiError)")
                }
            }
        }
    }
}

