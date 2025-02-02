//
//  APIClientTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-01.
//

import Foundation
import Mockable
import Testing
@testable import CartButler

struct APIClientTests {
  
  private struct MockCodable: Codable, Equatable {
    let message: String
    let number: Double?
    
    init(message: String, number: Double? = nil) {
      self.message = message
      self.number = number
    }
  }
  
  private let mockSession = MockNetworkSession()
  private let sut: APIClient
  private let mockEndpointURL = URL(string: "https://example.com/api/test")!
  private let requestBody = MockCodable(message: "Request")
  private let successBody = MockCodable(message: "Success")
  
  init() {
    sut = APIClient(
      baseURL: URL(string: "https://example.com/api")!,
      session: mockSession
    )
  }
  
  // MARK: - Successful responses
  
  @Test
  func testGetRequestSuccess() async throws {
    // Arrange
    let parameters = ["key1": "value 1"]
    let expectedURL = URL(string: "https://example.com/api/test?key1=value%201")!
    let expectedRequest = try buildURLRequest(url: expectedURL, method: "GET")
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildSuccessResponse())
    
    // Act
    let response: MockCodable = try await sut.get(path: "/test", queryParameters: parameters)
    
    // Assert
    #expect(response == successBody)
  }
  
  @Test
  func testPostRequestSuccess() async throws {
    // Arrange
    let expectedRequest = try buildURLRequest(method: "POST", body: requestBody)
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildSuccessResponse())
    
    // Act
    let response: MockCodable = try await sut.post(path: "/test", body: requestBody)
    
    // Assert
    #expect(response == successBody)
  }
  
  @Test
  func testEmptyResponsePostRequestSuccess() async throws {
    // Arrange
    let expectedRequest = try buildURLRequest(method: "POST", body: requestBody)
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildEmptySuccessResponse())
    
    // Act
    try await sut.post(path: "/test", body: requestBody)
    
    // Assert
    verify(mockSession)
      .data(for: .value(expectedRequest)).called(1)
  }
  
  @Test
  func testPutRequestSuccess() async throws {
    // Arrange
    let expectedRequest = try buildURLRequest(method: "PUT", body: requestBody)
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildSuccessResponse())
    
    // Act
    let response: MockCodable = try await sut.put(path: "/test", body: requestBody)
    
    // Assert
    #expect(response == successBody)
  }
  
  @Test
  func testEmptyResponsePutRequestSuccess() async throws {
    // Arrange
    let expectedRequest = try buildURLRequest(method: "PUT", body: requestBody)
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildEmptySuccessResponse())
    
    // Act
    try await sut.put(path: "/test", body: requestBody)
    
    // Assert
    verify(mockSession)
      .data(for: .value(expectedRequest)).called(1)
  }
  
  
  @Test
  func testDeleteRequestSuccess() async throws {
    // Arrange
    let expectedRequest = try buildURLRequest(method: "DELETE")
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildSuccessResponse())
    
    // Act
    let response: MockCodable = try await sut.delete(path: "/test", queryParameters: nil)
    
    // Assert
    #expect(response == successBody)
  }
  
  @Test
  func testEmptyResponseDeleteRequestSuccess() async throws {
    // Arrange
    let expectedRequest = try buildURLRequest(method: "DELETE")
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildEmptySuccessResponse())
    
    // Act
    try await sut.delete(path: "/test", queryParameters: nil)
    
    // Assert
    verify(mockSession)
      .data(for: .value(expectedRequest)).called(1)
  }
  
  // MARK: - Error responses
  
  @Test
  func testGetRequestInvalidURL() async throws {
    // Arrange
    let invalidURL = URL(string: "invalid")!
    let sut = APIClient(baseURL: invalidURL, session: mockSession)
    
    // Assert
    async #expect(performing: {
      // Act
      let _: MockCodable = try await sut.get(path: "//path")
    }, throws: { error in
      // Assert
      if case NetworkError.invalidURL = error { true }
      else { false }
    })
  }
  
  @Test
  func testGetRequestNetworkError() async throws {
    // Arrange
    given(mockSession)
      .data(for: .any)
      .willThrow(NSError(domain: "test", code: 0, userInfo: nil))
    
    async #expect(performing: {
      // Act
      let _: MockCodable = try await sut.get(path: "/test")
    }, throws: { error in
      // Assert
      if case NetworkError.requestFailed = error { true }
      else { false }
    })
  }
  
  @Test
  func testPostEncodingError() async throws {
    // Arrange
    let invalidBody = MockCodable(message: "message", number: .nan)
    
    async #expect(performing: {
      // Act
      let _:MockCodable = try await sut.post(path: "/test", body: invalidBody)
    }, throws: { error in
      // Assert
      if case NetworkError.encodingError = error { true }
      else { false }
    })
  }
  
  @Test
  func testPutRequestBadStatusCode() async throws {
    // Arrange
    let errorResponse = "Bad Request"
    given(mockSession)
      .data(for: .any)
      .willReturn(try buildResponse(response: errorResponse.data(using: .utf8), statusCode: 400))
    
    async #expect(performing: {
      // Act
      let _:MockCodable = try await sut.put(path: "/test", body: requestBody)
    }, throws: { error in
      // Assert
      if case NetworkError.badStatusCode(let receivedError as NSError) = error {
        receivedError.code == 400 &&
        receivedError.userInfo["response"] as? String == errorResponse
      }
      else { false }
    })
  }
  
  // MARK: - Helper methods
  
  private func buildURLRequest(
    url: URL? = nil,
    method: String,
    body: MockCodable? = nil
  ) throws -> URLRequest {
    var request = URLRequest(url: url ?? mockEndpointURL)
    request.httpMethod = method
    try body.flatMap {
      request.httpBody = try JSONEncoder().encode($0)
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    return request
  }
  
  private func buildSuccessResponse() throws -> (Data, URLResponse) {
    try buildResponse()
  }
  
  private func buildEmptySuccessResponse() throws -> (Data, URLResponse) {
    try buildResponse(response: Data())
  }
  
  private func buildResponse(
    expectedURL: URL? = nil,
    response: Data? = nil,
    statusCode: Int? = nil
  ) throws -> (Data, URLResponse) {
    (
      try response ?? JSONEncoder().encode(self.successBody),
      HTTPURLResponse(
        url: expectedURL ?? self.mockEndpointURL,
        statusCode: statusCode ?? 200,
        httpVersion: nil,
        headerFields: nil
      )!
    )
  }
}
