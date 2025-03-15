//
//  CartViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Combine
import Foundation

@MainActor
final class CartViewModel: ObservableObject {
  @Published var cart: CartDTO = .empty
  @Published var errorMessage: String?
  @Published var showAlert = false

  private let cartRepository: CartRepositoryProvider
  private var viewAppeared = false

  init(cartRepository: CartRepositoryProvider = CartRepository.shared) {
    self.cartRepository = cartRepository
  }

  func viewDidAppear() {
    guard !viewAppeared else { return }
    viewAppeared = true
    cartRepository.cartPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &$cart)
  }

  func incrementQuantity(for productId: Int) async {
    do {
      try await cartRepository.increment(productId: productId)
    } catch {
      errorMessage = "Failed to update cart quantity"
      showAlert = true
    }
  }

  func decrementQuantity(for productId: Int) async {
    do {
      try await cartRepository.decrement(productId: productId)
    } catch {
      errorMessage = "Failed to update cart quantity"
      showAlert = true
    }
  }
}
