//
//  CartRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Combine
import Foundation
import Mockable

@globalActor
actor CartActor: GlobalActor {
  static let shared = CartActor()
}

@Mockable
protocol CartRepositoryProvider: Sendable {
  var cartPublisher: AnyPublisher<CartDTO?, Never> { get }
  func refreshCart() async throws
  func increment(productId: Int) async throws
  func decrement(productId: Int) async throws
  func setQuantity(productId: Int, quantity: Int) async throws
  func removeFromCart(productId: Int) async throws
}

final class CartRepository: CartRepositoryProvider, @unchecked Sendable {

  static let shared = CartRepository()

  @CartActor @Published private var cart: CartDTO?

  var cartPublisher: AnyPublisher<CartDTO?, Never> {
    $cart
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  private let apiService: APIServiceProvider

  @CartActor private var addToCartTask: Task<Void, Error>?
  @CartActor private var tempItems: [Int: Int] = [:]

  init(apiService: APIServiceProvider = APIService.shared) {
    self.apiService = apiService
  }

  @CartActor
  func refreshCart() async throws {
    cart = try await apiService.fetchCart()
  }

  @CartActor
  func increment(productId: Int) async throws {
    try await addToCart(productId: productId, increment: 1)
  }

  @CartActor
  func decrement(productId: Int) async throws {
    try await addToCart(productId: productId, increment: -1)
  }
  
  
  @CartActor
  func setQuantity(productId: Int, quantity: Int) async throws {
    try await addToCart(productId: productId, setQuantity: quantity)
  }

  @CartActor
  func removeFromCart(productId: Int) async throws {
    addToCartTask?.cancel()
    addToCartTask = Task {
      // Handle any pending temp items first
      try await handleTempItems(for: productId)

      // Remove the item from temp items if it exists
      tempItems.removeValue(forKey: productId)

      // Update the cart with quantity 0 to remove the item
      try await updateCart(productId: productId, quantity: 0)
    }

    // Wait for task value to rethrow error if it fails
    do {
      try await addToCartTask?.value
    } catch is CancellationError {
      // Don't rethrow if task was cancelled
    }
  }

  @CartActor
  private func addToCart(productId: Int, increment: Int = 0, setQuantity: Int? = nil) async throws {
    addToCartTask?.cancel()
    addToCartTask = Task {
      // Handle any pending temp items first
      try await handleTempItems(for: productId)

      // Increment the quantity based on temp items first.
      // If no temp item exists, get the item from the current cart.
      // If the item is not in the cart, default to 0.
      let itemFromCart = cart?.cartItems.first { $0.productId == productId }
      if let setQuantity {
        tempItems[productId] = setQuantity
      } else {
        tempItems[productId] = (tempItems[productId] ?? itemFromCart?.quantity ?? 0) + increment
      }

      // Debounce consecutive calls to avoid multiple network requests
      try await Task.sleep(for: .seconds(0.5))

      // Make sure to not update the cart if the task was cancelled.
      // The item should be removed from the temp items dictionary when the request is made.
      if !Task.isCancelled, let quantity = tempItems.removeValue(forKey: productId) {
        try await updateCart(productId: productId, quantity: quantity)
      }
    }

    // Wait task value to rethrow error if it fails.
    do {
      try await addToCartTask?.value
    } catch is CancellationError {
      // Don't rethrow if task was cancelled
    }
  }

  @CartActor
  private func handleTempItems(for productId: Int) async throws {
    // We need to keep track of temp items that are out-of-sync with the backend cart
    if tempItems[productId] == nil && tempItems.count > 0 {
      for (productId, quantity) in tempItems {
        try await updateCart(productId: productId, quantity: quantity)
      }
      tempItems = [:]
    }
  }

  @CartActor
  private func updateCart(productId: Int, quantity: Int) async throws {
    cart = try await apiService.addToCart(productId: productId, quantity: quantity)
  }

}
