//
//  ShoppingResultsViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Foundation

@MainActor
final class ShoppingResultsViewModel: ObservableObject {
  @Published private(set) var results: [ShoppingResultsDTO]?
  @Published private(set) var isLoading = false
  @Published var showAlert = false
  @Published var errorMessage: String? {
    didSet { if errorMessage?.isEmpty == false { showAlert = true } }
  }

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
    }

    isLoading = false
  }
}
