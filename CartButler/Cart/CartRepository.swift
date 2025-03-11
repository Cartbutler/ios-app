//
//  CartRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Combine
import Mockable

@Mockable
protocol CartRepositoryProvider {
  var cartPublisher: AnyPublisher<CartDTO?, Never> { get }
  func refreshCart() async throws
  func addToCart(productId: Int) async throws
}

final class CartRepository: CartRepositoryProvider {

  private let apiService: APIServiceProvider
  private var addToCartTask: Task<Void, Error>?

  var cartPublisher: AnyPublisher<CartDTO?, Never> {
    cartSubject.eraseToAnyPublisher()
  }

  @MainActor private var tempItems: [Int: Int] = [:]

  init(
    apiService: APIServiceProvider = APIService.shared
  ) {
    self.apiService = apiService
  }

  private let cartSubject = CurrentValueSubject<CartDTO?, Never>(nil)

  func refreshCart() async throws {
    cartSubject.send(
      try await apiService.fetchCart()
    )
  }

  @MainActor
  func addToCart(productId: Int) async throws {
    addToCartTask?.cancel()
    addToCartTask = Task {

      if tempItems[productId] == nil && tempItems.count > 0 {
        for (productId, quantity) in tempItems {
          try await updateCart(productId: productId, quantity: quantity)
        }
        tempItems = [:]
      }

      // Increment
      tempItems[productId] = (tempItems[productId] ?? 0) + 1

      // Debounce consecutive calls
      try await Task.sleep(for: .seconds(0.5))
      
      if !Task.isCancelled, let quantity = tempItems.removeValue(forKey: productId) {
        try await updateCart(productId: productId, quantity: quantity)
      }
    }

    // Rethrow error if task fails
    do {
      try await addToCartTask?.value
    } catch is CancellationError {
      // Don't rethrow if task was cancelled
    }
  }

  private func updateCart(productId: Int, quantity: Int) async throws {
    let cart = try await apiService.addToCart(productId: productId, quantity: quantity)
    cartSubject.send(cart)
  }

}
