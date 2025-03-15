//
//  CartViewModelTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Combine
import Foundation
import Mockable
import Testing

@testable import CartButler

@MainActor
struct CartViewModelTests {

  private let mockCartRepository = MockCartRepositoryProvider()
  private let mockCartSubject = PassthroughSubject<CartDTO, Never>()
  private let sut: CartViewModel
  private let mockCart = CartDTO(cartItems: [
    .init(id: 1, cartId: 1, productId: 1, quantity: 2, product: .empty)
  ])

  init() {
    sut = CartViewModel(cartRepository: mockCartRepository)
    given(mockCartRepository)
      .cartPublisher
      .willReturn(mockCartSubject.eraseToAnyPublisher())
    given(mockCartRepository)
      .increment(productId: .any)
      .willReturn()
    given(mockCartRepository)
      .decrement(productId: .any)
      .willReturn()
  }

  // MARK: - Cart Updates

  @Test
  func viewDidAppearShouldSubscribeToCartUpdates() async throws {
    // Given
    #expect(sut.cart.cartItems.isEmpty)
    sut.viewDidAppear()

    // When
    mockCartSubject.send(mockCart)

    // Then
    let result = await sut.$cart.values.first(where: { !$0.isEmpty })
    #expect(result == mockCart)
  }

  @Test
  func viewDidAppearShouldOnlySubscribeOnce() async throws {
    // Given
    sut.viewDidAppear()
    sut.viewDidAppear()

    // When
    mockCartSubject.send(mockCart)

    // Then
    verify(mockCartRepository)
      .cartPublisher
      .called(1)
  }

  // MARK: - Increment Quantity

  @Test
  func incrementQuantitySuccess() async throws {
    // Given
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)

    // When
    await sut.incrementQuantity(for: 1)

    // Then
    verify(mockCartRepository)
      .increment(productId: .value(1))
      .called(1)
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
  }

  @Test
  func incrementQuantityFailure() async throws {
    // Given
    mockCartRepository.reset()
    given(mockCartRepository)
      .increment(productId: .any)
      .willThrow(NetworkError.invalidResponse)
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)

    // When
    await sut.incrementQuantity(for: 1)

    // Then
    #expect(sut.errorMessage != nil)
    #expect(sut.showAlert == true)
  }

  // MARK: - Decrement Quantity

  @Test
  func decrementQuantitySuccess() async throws {
    // Given
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)

    // When
    await sut.decrementQuantity(for: 1)

    // Then
    verify(mockCartRepository)
      .decrement(productId: .value(1))
      .called(1)
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
  }

  @Test
  func decrementQuantityFailure() async throws {
    // Given
    mockCartRepository.reset()
    given(mockCartRepository)
      .decrement(productId: .any)
      .willThrow(NetworkError.invalidResponse)
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)

    // When
    await sut.decrementQuantity(for: 1)

    // Then
    verify(mockCartRepository)
      .decrement(productId: .value(1))
      .called(1)
    #expect(sut.errorMessage != nil)
    #expect(sut.showAlert == true)
  }
}
