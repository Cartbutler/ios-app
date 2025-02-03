//
//  Network.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-29.
//

import Foundation
import Mockable

@Mockable
protocol NetworkSession: Sendable {
  func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

enum NetworkError: Error {
  case invalidURL
  case invalidResponse
  case requestFailed(Error)
  case badStatusCode(Error)
  case decodingError(Error)
  case encodingError(Error)
}

private enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

final class APIClient: APIClientProvider, Sendable {

  static let shared = APIClient()

  static private let defaulURL = URL(
    string: "https://southern-shard-449119-d4.nn.r.appspot.com/api")!

  private let baseURL: URL
  private let session: NetworkSession

  init(baseURL: URL = APIClient.defaulURL, session: NetworkSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
  }

  // MARK: - Specific HTTP Method Wrappers

  func get<T: Decodable>(
    path: String,
    queryParameters: [String: String]? = nil
  ) async throws -> T {
    try await performRequest(path: path, method: .get, queryParameters: queryParameters)
  }

  func post<T: Decodable, U: Encodable>(
    path: String,
    body: U
  ) async throws -> T {
    try await performRequest(path: path, method: .post, body: body)
  }

  func post<U: Encodable>(
    path: String,
    body: U
  ) async throws {
    try await performEmptyResponseRequest(path: path, method: .post, body: body)
  }

  func put<T: Decodable, U: Encodable>(
    path: String,
    body: U
  ) async throws -> T {
    try await performRequest(path: path, method: .put, body: body)
  }

  func put<U: Encodable>(
    path: String,
    body: U
  ) async throws {
    try await performEmptyResponseRequest(path: path, method: .put, body: body)
  }

  func delete<T: Decodable>(
    path: String,
    queryParameters: [String: String]? = nil
  ) async throws -> T {
    try await performRequest(path: path, method: .delete, queryParameters: queryParameters)
  }

  func delete(
    path: String,
    queryParameters: [String: String]? = nil
  ) async throws {
    try await performEmptyResponseRequest(
      path: path, method: .delete, queryParameters: queryParameters)
  }

  // MARK: - Generic Request Method

  private func performRequest<T: Decodable>(
    path: String,
    method: HTTPMethod,
    queryParameters: [String: String]? = nil,
    body: Encodable? = nil
  ) async throws -> T {

    guard
      var urlComponents = URLComponents(
        url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
    else {
      throw NetworkError.invalidURL
    }

    if let queryParameters = queryParameters {
      urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }

    guard let url = urlComponents.url else {
      throw NetworkError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue

    if let body = body {
      do {
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      } catch {
        throw NetworkError.encodingError(error)
      }
    }

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await session.data(for: request)
    } catch {
      throw NetworkError.requestFailed(error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      let userInfo = String(data: data, encoding: .utf8).flatMap { ["response": $0] }
      let error = NSError(
        domain: "Network error", code: httpResponse.statusCode, userInfo: userInfo)
      throw NetworkError.badStatusCode(error)
    }

    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw NetworkError.decodingError(error)
    }
  }

  private func performEmptyResponseRequest(
    path: String,
    method: HTTPMethod,
    queryParameters: [String: String]? = nil,
    body: Encodable? = nil
  ) async throws {
    do {
      let _: EmptyResponse = try await performRequest(
        path: path, method: method, queryParameters: queryParameters, body: body)
    } catch NetworkError.decodingError {
      // Ignore decoding error for empty response
    } catch {
      throw error
    }
  }

  // Empty type for requests without response
  private struct EmptyResponse: Codable {}
}
