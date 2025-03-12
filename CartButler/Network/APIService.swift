//
//  APIService.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-05.
//

import Foundation
import Mockable
import UIKit

@Mockable
protocol APIServiceProvider: Sendable {
  func fetchCategories() async throws -> [CategoryDTO]
  func fetchSuggestions(query: String) async throws -> [SuggestionDTO]
  func fetchProducts(query: String) async throws -> [BasicProductDTO]
  func fetchProducts(categoryID: Int) async throws -> [BasicProductDTO]
  func fetchProduct(id: Int) async throws -> ProductDTO
  func fetchCart() async throws -> CartDTO
  func addToCart(productId: Int, quantity: Int) async throws -> CartDTO
}

final class APIService: APIServiceProvider {

  static let shared = APIService()

  private let apiClient: APIClientProvider

  private var sessionID: String {
    get async throws {
      guard let sessionID = await UIDevice.current.identifierForVendor?.uuidString else {
        throw NetworkError.invalidSession
      }
      return sessionID
    }
  }

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

  func fetchCart() async throws -> CartDTO {
    try await apiClient.get(path: "cart", queryParameters: ["userId": sessionID])
  }

  func addToCart(productId: Int, quantity: Int) async throws -> CartDTO {
    try await apiClient.post(
      path: "cart",
      body: AddToCartDTO(userId: sessionID, productId: productId, quantity: quantity)
    )
  }
}
