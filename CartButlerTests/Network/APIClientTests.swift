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
    let messageId: Int
    let message: String
    let number: Double?
    let date: Date

    init(message: String, number: Double? = nil) {
      self.messageId = 1
      self.message = message
      self.number = number
      self.date = Date()
    }
  }

  private let mockSession = MockNetworkSession()
  private let mockLanguageService = MockLanguageServiceProvider()
  private let sut: APIClient
  private let mockEndpointURL = URL(string: "https://example.com/api/test?language_id=pt-BR")!
  private let requestBody = "{ \"message_id\": 1, \"message\": \"request\" }"
  private let successBody =
    """
    {
      \"message_id\": 1, 
      \"message\": \"success\" , 
      \"date\": \"2025-02-11T23:57:56.000Z\"
    }
    """

  init() {
    sut = APIClient(
      baseURL: URL(string: "https://example.com/api")!,
      session: mockSession,
      languageService: mockLanguageService
    )
    given(mockLanguageService)
      .languageID
      .willReturn("pt-BR")
  }

  // MARK: - Successful responses

  @Test
  func testGetRequestSuccess() async throws {
    // Given
    let parameters = ["key1": "value 1"]
    given(mockSession)
      .data(
        for: .matching {
          $0.url?.absoluteString.contains("https://example.com/api/test?") == true
            && $0.url?.absoluteString.contains("language_id=pt-BR") == true
            && $0.url?.absoluteString.contains("key1=value%201") == true
        }
      )
      .willReturn(try buildSuccessResponse())

    // When
    let response: MockCodable = try await sut.get(path: "/test", queryParameters: parameters)

    // Then
    #expect(response.message == "success")
  }

  @Test
  func testPostRequestSuccess() async throws {
    // Given
    let expectedRequest = try buildURLRequest(method: "POST", body: requestBody)
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildSuccessResponse())

    // When
    let response: MockCodable = try await sut.post(path: "/test", body: requestBody)

    // Then
    #expect(response.message == "success")
  }

  @Test
  func testEmptyResponsePostRequestSuccess() async throws {
    // Given
    let expectedRequest = try buildURLRequest(method: "POST", body: requestBody)
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildEmptySuccessResponse())

    // When
    try await sut.post(path: "/test", body: requestBody)

    // Then
    verify(mockSession)
      .data(for: .value(expectedRequest)).called(1)
  }

  @Test
  func testPutRequestSuccess() async throws {
    // Given
    let expectedRequest = try buildURLRequest(method: "PUT", body: requestBody)
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildSuccessResponse())

    // When
    let response: MockCodable = try await sut.put(path: "/test", body: requestBody)

    // Then
    #expect(response.message == "success")
  }

  @Test
  func testEmptyResponsePutRequestSuccess() async throws {
    // Given
    let expectedRequest = try buildURLRequest(method: "PUT", body: requestBody)
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildEmptySuccessResponse())

    // When
    try await sut.put(path: "/test", body: requestBody)

    // Then
    verify(mockSession)
      .data(for: .value(expectedRequest)).called(1)
  }

  @Test
  func testDeleteRequestSuccess() async throws {
    // Given
    let expectedRequest = try buildURLRequest(method: "DELETE")
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildSuccessResponse())

    // When
    let response: MockCodable = try await sut.delete(path: "/test", queryParameters: nil)

    // Then
    #expect(response.message == "success")
  }

  @Test
  func testEmptyResponseDeleteRequestSuccess() async throws {
    // Given
    let expectedRequest = try buildURLRequest(method: "DELETE")
    given(mockSession)
      .data(for: .value(expectedRequest))
      .willReturn(try buildEmptySuccessResponse())

    // When
    try await sut.delete(path: "/test", queryParameters: nil)

    // Then
    verify(mockSession)
      .data(for: .value(expectedRequest)).called(1)
  }

  // MARK: - Error responses

  @Test
  func testGetRequestNetworkError() async throws {
    // Given
    let expectedError = NSError(domain: "test", code: 0, userInfo: nil)
    given(mockSession)
      .data(for: .any)
      .willThrow(expectedError)

    // Then
    await #expect(throws: NetworkError.requestFailed(expectedError)) {
      // When
      let _: MockCodable = try await sut.get(path: "/test")
    }
  }

  @Test
  func testPostEncodingError() async throws {
    // Given
    let invalidBody = MockCodable(message: "message", number: .nan)

    do {
      // When
      let _: MockCodable = try await sut.post(path: "/test", body: invalidBody)
      Issue.record("Failed to throw error")
    } catch {
      // Then
      if case NetworkError.encodingError = error {
      } else {
        Issue.record(error, "Unexpected error thrown")
      }
    }
  }

  @Test
  func testPutRequestBadStatusCode() async throws {
    // Given
    let errorResponse = "Bad Request"
    given(mockSession)
      .data(for: .any)
      .willReturn(try buildResponse(response: errorResponse, statusCode: 400))

    let expectedError = NSError(
      domain: "Network error", code: 400, userInfo: ["response": errorResponse])

    // Then
    await #expect(throws: NetworkError.badStatusCode(expectedError)) {
      // When
      let _: MockCodable = try await sut.put(path: "/test", body: requestBody)
    }
  }

  // MARK: - Helper methods

  private func buildURLRequest(
    url: URL? = nil,
    method: String,
    body: String? = nil
  ) throws -> URLRequest {
    var request = URLRequest(url: url ?? mockEndpointURL)
    request.httpMethod = method
    body.flatMap {
      request.httpBody = $0.data(using: .utf8)
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    return request
  }

  private func buildSuccessResponse() throws -> (Data, URLResponse) {
    try buildResponse()
  }

  private func buildEmptySuccessResponse() throws -> (Data, URLResponse) {
    try buildResponse(response: "")
  }

  private func buildResponse(
    expectedURL: URL? = nil,
    response: String? = nil,
    statusCode: Int? = nil
  ) throws -> (Data, URLResponse) {
    let body = try #require((response ?? self.successBody).data(using: .utf8))
    return (
      body,
      HTTPURLResponse(
        url: expectedURL ?? self.mockEndpointURL,
        statusCode: statusCode ?? 200,
        httpVersion: nil,
        headerFields: nil
      )!
    )
  }
}
