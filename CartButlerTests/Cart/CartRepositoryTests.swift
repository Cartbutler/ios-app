//
//  CartRepositoryTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-09.
//

import Mockable
import Testing

@testable import CartButler

struct CartRepositoryTests {

  private let sut: CartRepository
  private let mockAPIService = MockAPIServiceProvider()

  init() {
    sut = CartRepository(apiService: mockAPIService)
  }

  // MARK: - refreshCart

  @Test
  func refreshCartSuccess() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      userId: "abc", cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 4)]
    )

    given(mockAPIService)
      .fetchCart()
      .willReturn(expectedResponse)

    // When
    try await sut.refreshCart()
    let result = try await sut.cartPublisher.values.first()

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func refreshCartFailure() async throws {
    // Given
    given(mockAPIService)
      .fetchCart()
      .willProduce { throw NetworkError.invalidResponse }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.refreshCart()
    }
  }

  // MARK: - addToCart

  @Test
  func addToCartSuccess() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      userId: "abc", cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 1)]
    )
    given(mockAPIService)
      .addToCart(productId: .value(3), quantity: .value(1))
      .willReturn(expectedResponse)

    // When
    try await sut.addToCart(productId: 3)

    // Then
    let result = await sut.cartPublisher.values.first(where: { $0 != nil })
    #expect(result == expectedResponse)
  }

  @Test
  func addToCartFailure() async throws {
    // Given
    given(mockAPIService)
      .addToCart(productId: .any, quantity: .any)
      .willProduce { _, _ in throw NetworkError.invalidResponse }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      try await sut.addToCart(productId: 3)
    }
  }

  @Test
  func subsequentCallShouldDebounce() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      userId: "abc", cartItems: [.init(id: 1, cartId: 2, productId: 4, quantity: 3)]
    )
    given(mockAPIService)
      .addToCart(productId: .value(4), quantity: .value(3))
      .willReturn(expectedResponse)

    // When
    async let task1: () = try await sut.addToCart(productId: 4)
    async let task2: () = try await sut.addToCart(productId: 4)
    async let task3: () = try await sut.addToCart(productId: 4)
    _ = try await (task1, task2, task3)

    // Then
    let result = await sut.cartPublisher.values.first(where: { $0 != nil })
    #expect(result == expectedResponse)
  }
}
