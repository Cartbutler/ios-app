//
//  ProductsResultsViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-12.
//
import Foundation

enum SearchType {
  case query(String)
  case category(Category)
}

@MainActor
final class ProductsResultsViewModel: ObservableObject {
  @Published var products: [BasicProductDTO] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let apiService: APIServiceProvider
  private let searchType: SearchType

  init(apiService: APIServiceProvider = APIService.shared, searchType: SearchType) {
    self.searchType = searchType
    self.apiService = apiService
  }

  var navigationTitle: String {
    switch searchType {
    case .query(let query):
      return "Results for \"\(query)\""
    case .category(let category):
      return category.name
    }
  }

  func fetchProducts() async {
    guard !isLoading, products.isEmpty else { return }
    isLoading = true
    errorMessage = nil

    do {
      switch searchType {
      case .query(let query):
        products = try await apiService.fetchProducts(query: query)
      case .category(let category):
        products = try await apiService.fetchProducts(categoryID: category.id)
      }
    } catch {
      errorMessage = "Failed to load products: \(error.localizedDescription)"
    }

    isLoading = false
  }
}
