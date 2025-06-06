//
//  CartRepositoryTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-09.
//

import Mockable
import Testing

@testable import CartButler

@MainActor
struct CartRepositoryTests {

  private let sut: CartRepository
  private let mockAPIService = MockAPIServiceProvider()

  init() async {
    sut = CartRepository(apiService: mockAPIService)
  }

  // MARK: - refreshCart

  @Test
  func refreshCartSuccess() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 4, product: .empty)]
    )

    given(mockAPIService)
      .fetchCart()
      .willReturn(expectedResponse)

    // When
    try await sut.refreshCart()
    let result = await sut.cartPublisher.values.first(where: { $0?.isEmpty == false })

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

  // MARK: - increment

  @Test
  func incrementSuccess() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 1, product: .empty)]
    )
    given(mockAPIService)
      .addToCart(productId: .value(3), quantity: .value(1))
      .willReturn(expectedResponse)

    // When
    try await sut.increment(productId: 3)

    // Then
    let result = await sut.cartPublisher.values.first(where: { $0?.isEmpty == false })
    #expect(result == expectedResponse)
  }

  @Test
  func incrementFailure() async throws {
    // Given
    given(mockAPIService)
      .addToCart(productId: .any, quantity: .any)
      .willProduce { _, _ in throw NetworkError.invalidResponse }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      try await sut.increment(productId: 3)
    }
  }

  // MARK: - decrement

  @Test
  func decrementSuccess() async throws {
    // Given
    let incrementResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 1, product: .empty)]
    )
    given(mockAPIService)
      .addToCart(productId: .value(3), quantity: .value(1))
      .willReturn(incrementResponse)
    try await sut.increment(productId: 3)

    let expectedDecrementResponse = CartDTO(id: 1, cartItems: [])
    given(mockAPIService)
      .addToCart(productId: .value(3), quantity: .value(0))
      .willReturn(expectedDecrementResponse)

    // When
    try await sut.decrement(productId: 3)

    // Then
    let result = await sut.cartPublisher.values.first(where: { $0?.isEmpty == true })
    #expect(result == expectedDecrementResponse)
  }

  @Test
  func decrementFailure() async throws {
    // Given
    let incrementResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 1, product: .empty)]
    )
    given(mockAPIService)
      .addToCart(productId: .value(3), quantity: .value(1))
      .willReturn(incrementResponse)
    try await sut.increment(productId: 3)

    given(mockAPIService)
      .addToCart(productId: .any, quantity: .any)
      .willProduce { _, _ in throw NetworkError.invalidResponse }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      try await sut.decrement(productId: 3)
    }
  }

  // MARK: - removeFromCart

  @Test
  func removeFromCartSuccess() async throws {
    // Given
    let initialCart = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 2, product: .empty)]
    )
    given(mockAPIService)
      .fetchCart()
      .willReturn(initialCart)
    try await sut.refreshCart()
    let currentCart = try await sut.cartPublisher.values.first()
    #expect(currentCart == initialCart)

    let expectedResponse = CartDTO(id: 1, cartItems: [])
    given(mockAPIService)
      .addToCart(productId: .value(3), quantity: .value(0))
      .willReturn(expectedResponse)

    // When
    try await sut.removeFromCart(productId: 3)

    // Then
    let result = await sut.cartPublisher.values.first(where: { $0?.isEmpty == true })
    #expect(result == expectedResponse)
  }

  @Test
  func removeFromCartFailure() async throws {
    // Given
    given(mockAPIService)
      .addToCart(productId: .any, quantity: .any)
      .willProduce { _, _ in throw NetworkError.invalidResponse }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      try await sut.removeFromCart(productId: 3)
    }
  }

  // MARK: - debonce

  @Test
  func subsequentIncrementCallShouldDebounce() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 4, quantity: 3, product: .empty)]
    )
    given(mockAPIService)
      .addToCart(productId: .value(4), quantity: .value(3))
      .willReturn(expectedResponse)

    // When
    async let task1: () = try await sut.increment(productId: 4)
    async let task2: () = try await sut.increment(productId: 4)
    async let task3: () = try await sut.increment(productId: 4)
    _ = try await (task1, task2, task3)

    // Then
    let result = await sut.cartPublisher.values.first(where: { $0 != nil })
    #expect(result == expectedResponse)
  }

  @Test
  func subsequentDecrementCallShouldDebounce() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 4, quantity: 1, product: .empty)]
    )
    given(mockAPIService)
      .addToCart(productId: .value(4), quantity: .value(1))
      .willReturn(expectedResponse)

    // When
    async let task1: () = try await sut.increment(productId: 4)
    async let task3: () = try await sut.decrement(productId: 4)
    async let task2: () = try await sut.increment(productId: 4)
    _ = try await (task1, task2, task3)

    // Then
    let result = await sut.cartPublisher.values.first(where: { $0?.isEmpty == false })
    #expect(result == expectedResponse)
  }
}
