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

enum NetworkError: Error, Equatable {
  case invalidURL
  case invalidResponse
  case invalidSession
  case requestFailed(Error)
  case badStatusCode(Error)
  case decodingError(Error)
  case encodingError(Error)

  static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
    switch (lhs, rhs) {
    case (.invalidURL, .invalidURL),
      (.invalidResponse, .invalidResponse):
      true
    case (.requestFailed(let lhs), .requestFailed(let rhs)),
      (.badStatusCode(let lhs), .badStatusCode(let rhs)),
      (.decodingError(let lhs), .decodingError(let rhs)),
      (.encodingError(let lhs), .encodingError(let rhs)):
      lhs as NSError == rhs as NSError
    default:
      false
    }
  }
}

private enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

final class APIClient: APIClientProvider {

  static let shared = APIClient()

  static private let defaulURL = URL(
    string: "https://cartbutler.duckdns.org/api")!

  private let baseURL: URL
  private let session: NetworkSession
  private let decoder: JSONDecoder
  private let encoder: JSONEncoder
  private let languageService: LanguageServiceProvider

  init(
    baseURL: URL = APIClient.defaulURL,
    session: NetworkSession = URLSession.shared,
    languageService: LanguageServiceProvider = LanguageService.shared
  ) {
    self.baseURL = baseURL
    self.session = session
    self.languageService = languageService

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

    decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .formatted(dateFormatter)
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

  func put<T: Decodable, U: Encodable>(
    path: String,
    body: U
  ) async throws -> T {
    try await performRequest(path: path, method: .put, body: body)
  }

  func delete<T: Decodable>(
    path: String,
    queryParameters: [String: String]? = nil
  ) async throws -> T {
    try await performRequest(path: path, method: .delete, queryParameters: queryParameters)
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

    var queryParameters = queryParameters ?? [:]
    queryParameters["language_id"] = languageService.languageID
    urlComponents.queryItems = queryParameters.map {
      URLQueryItem(name: $0.key, value: $0.value)
    }

    guard let url = urlComponents.url else {
      throw NetworkError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue

    if let body = body {
      do {
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      } catch {
        throw NetworkError.encodingError(error)
      }
    }

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await session.data(for: request)
    } catch {
      print(error)
      throw NetworkError.requestFailed(error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      let userInfo = String(data: data, encoding: .utf8).flatMap { ["response": $0] }
      let error = NSError(
        domain: "Network error", code: httpResponse.statusCode, userInfo: userInfo)
      print(error)
      throw NetworkError.badStatusCode(error)
    }

    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      print(error)
      throw NetworkError.decodingError(error)
    }
  }
}
