//
//  ShoppingResultsViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Foundation

@MainActor
final class ShoppingResultsViewModel: ObservableObject {
  @Published var results: [ShoppingResultsDTO]?
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var showAlert = false

  private let apiService: APIServiceProvider
  private let cartRepository: CartRepositoryProvider

  init(
    apiService: APIServiceProvider = APIService.shared,
    cartRepository: CartRepositoryProvider = CartRepository.shared
  ) {
    self.apiService = apiService
    self.cartRepository = cartRepository
  }

  func fetchResults() async {
    guard !isLoading, results == nil else { return }
    isLoading = true
    errorMessage = nil

    do {
      if let cartId = try await cartRepository.cartPublisher.values.first()?.cartItems.first?.cartId
      {
        results = try await apiService.fetchShoppingResults(cartId: cartId)
      } else {
        errorMessage = "No items in cart"
      }
    } catch {
      errorMessage = "Failed to load shopping results: \(error.localizedDescription)"
      showAlert = true
    }

    isLoading = false
  }
}
