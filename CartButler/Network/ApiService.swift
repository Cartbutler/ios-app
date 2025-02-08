//
//  ApiService.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-05.
//

import Foundation
import Mockable

@Mockable
protocol APIServiceProvider: Sendable {
  func fetchCategories() async throws -> [CategoryDTO]
}

final class APIService: APIServiceProvider {
  private let apiClient: APIClientProvider

  init(apiClient: APIClientProvider = APIClient.shared) {
    self.apiClient = apiClient
  }

  func fetchCategories() async throws -> [CategoryDTO] {
    try await apiClient.get(path: "categories")
  }
}
