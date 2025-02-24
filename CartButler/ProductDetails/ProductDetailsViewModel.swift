//
//  ProductDetailsViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-21.
//
import Foundation

@MainActor
final class ProductDetailsViewModel: ObservableObject {
  @Published var product: ProductDTO?
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let apiService: APIServiceProvider
  private let productID: Int

  init(apiService: APIServiceProvider = APIService.shared, productID: Int) {
    self.productID = productID
    self.apiService = apiService
  }

  func fetchProduct() async {
    guard !isLoading, product == nil else { return }
    isLoading = true
    errorMessage = nil

    do {
      product = try await apiService.fetchProduct(id: productID)
    } catch {
      errorMessage = "Failed to load product details: \(error.localizedDescription)"
    }

    isLoading = false
  }
}
