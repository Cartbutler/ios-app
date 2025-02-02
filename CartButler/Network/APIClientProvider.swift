//
//  APIClientProvider.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-01.
//

protocol APIClientProvider {
  
  /// Performs a GET request
  /// - Parameters:
  ///   - path: The path to append to the base URL
  ///   - queryParameters: Optional query parameters
  /// - Returns: The decoded response object
  /// - Throws: An error if the request fails or the response cannot be decoded
  /// - Note: The queryParameters parameter is a dictionary of key-value pairs that will be appended to the URL as query parameters
  func get<T: Decodable>(
    path: String,
    queryParameters: [String: String]?
  ) async throws -> T
  
  /// Performs a POST request
  /// - Parameters:
  ///   - path: The path to append to the base URL
  ///   - body: The request body
  /// - Returns: The decoded response object
  /// - Throws: An error if the request fails or the response cannot be decoded
  /// - Note: The body parameter must conform to `Encodable`
  func post<T: Decodable, U: Encodable>(
    path: String,
    body: U
  ) async throws -> T
  
  /// Performs a POST request
  /// - Parameters:
  ///   - path: The path to append to the base URL
  ///   - body: The request body
  /// - Returns: The decoded response object
  /// - Throws: An error if the request fails or the response cannot be decoded
  /// - Note: The body parameter must conform to `Encodable`
  /// - Note: This method is useful for requests that do not expect a response body
  func post<U: Encodable>(
    path: String,
    body: U
  ) async throws
  
  /// Performs a PUT request
  /// - Parameters:
  ///   - path: The path to append to the base URL
  ///   - body: The request body
  /// - Returns: The decoded response object
  /// - Throws: An error if the request fails or the response cannot be decoded
  /// - Note: The body parameter must conform to `Encodable`
  func put<T: Decodable, U: Encodable>(
    path: String,
    body: U
  ) async throws -> T
  
  /// Performs a PUT request
  /// - Parameters:
  ///   - path: The path to append to the base URL
  ///   - body: The request body
  /// - Returns: The decoded response object
  /// - Throws: An error if the request fails or the response cannot be decoded
  /// - Note: The body parameter must conform to `Encodable`
  /// - Note: This method is useful for requests that do not expect a response body
  func put<U: Encodable>(
    path: String,
    body: U
  ) async throws
  
  /// Performs a DELETE request
  /// - Parameters:
  ///   - path: The path to append to the base URL
  ///   - queryParameters: Optional query parameters
  /// - Returns: The decoded response object
  /// - Throws: An error if the request fails or the response cannot be decoded
  /// - Note: The queryParameters parameter is a dictionary of key-value pairs that will be appended to the URL as query parameters
  func delete<T: Decodable>(
    path: String,
    queryParameters: [String: String]?
  ) async throws -> T
  
  /// Performs a DELETE request without expecting a response
  /// - Parameters:
  ///   - path: The path to append to the base URL
  ///   - queryParameters: Optional query parameters
  /// - Throws: An error if the request fails
  /// - Note: The queryParameters parameter is a dictionary of key-value pairs that will be appended to the URL as query parameters
  /// - Note: This method is useful for delete requests that do not return a response body
  func delete(
    path: String,
    queryParameters: [String: String]?
  ) async throws
}

extension APIClientProvider {
  
  /// Performs a GET request
  /// - Parameters:
  ///   - path: The path to append to the base URL
  /// - Returns: The decoded response object
  /// - Throws: An error if the request fails or the response cannot be decoded
  /// - Note: The queryParameters parameter is a dictionary of key-value pairs that will be appended to the URL as query parameters
  func get<T: Decodable>(
    path: String
  ) async throws -> T {
    try await get(path: path, queryParameters: nil)
  }
  
  /// Performs a DELETE request
  /// - Parameters:
  ///   - path: The path to append to the base URL
  /// - Returns: The decoded response object
  /// - Throws: An error if the request fails or the response cannot be decoded
  /// - Note: The queryParameters parameter is a dictionary of key-value pairs that will be appended to the URL as query parameters
  func delete<T: Decodable>(
    path: String
  ) async throws -> T {
    try await delete(path: path, queryParameters: nil)
  }
  
  /// Performs a DELETE request without expecting a response
  /// - Parameters:
  ///   - path: The path to append to the base URL
  /// - Throws: An error if the request fails
  /// - Note: The queryParameters parameter is a dictionary of key-value pairs that will be appended to the URL as query parameters
  /// - Note: This method is useful for delete requests that do not return a response body
  func delete(
    path: String
  ) async throws {
    try await delete(path: path, queryParameters: nil)
  }
}
