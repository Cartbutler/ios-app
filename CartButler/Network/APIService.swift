//
//  APIService.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-05.
//

import Foundation
import Mockable

@Mockable
protocol APIServiceProvider: Sendable {
  func fetchCategories() async throws -> [CategoryDTO]
  func fetchSuggestions(query: String) async throws -> [SuggestionDTO]
  func fetchProducts(query: String) async throws -> [BasicProductDTO]
  func fetchProducts(categoryID: Int) async throws -> [BasicProductDTO]
  func fetchProduct(id: Int) async throws -> ProductDTO
}

final class APIService: APIServiceProvider {

  static let shared = APIService()

  private let apiClient: APIClientProvider

  init(apiClient: APIClientProvider = APIClient.shared) {
    self.apiClient = apiClient
  }

  func fetchCategories() async throws -> [CategoryDTO] {
    try await apiClient.get(path: "categories")
  }

  func fetchSuggestions(query: String) async throws -> [SuggestionDTO] {
    try await apiClient.get(path: "suggestions", queryParameters: ["query": query])
  }

  func fetchProducts(query: String) async throws -> [BasicProductDTO] {
    try await apiClient.get(path: "search", queryParameters: ["query": query])
  }

  func fetchProducts(categoryID: Int) async throws -> [BasicProductDTO] {
    try await apiClient.get(path: "search", queryParameters: ["categoryID": String(categoryID)])
  }

  func fetchProduct(id: Int) async throws -> ProductDTO {
    try await apiClient.get(path: "product", queryParameters: ["id": String(id)])
  }
}
