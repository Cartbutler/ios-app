//
//  CartViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class CartViewModel: ObservableObject {
  @Published var cart: CartDTO?
  @Published var errorMessage: LocalizedStringKey?
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

  func removeItemsFromIndexSet(_ indexSet: IndexSet) async {
    guard let cart else { return }
    let productIds: [Int] = indexSet.compactMap { index in
      guard index < cart.cartItems.count else { return nil }
      return cart.cartItems[index].productId
    }

    for productId in productIds {
      do {
        try await cartRepository.removeFromCart(productId: productId)
      } catch {
        errorMessage = "Failed to remove item from cart"
        showAlert = true
      }
    }
  }
}
