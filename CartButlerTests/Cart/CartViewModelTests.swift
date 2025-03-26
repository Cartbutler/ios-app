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
  private let mockCartSubject = PassthroughSubject<CartDTO?, Never>()
  private let sut: CartViewModel
  private let mockCart = CartDTO(
    id: 1,
    cartItems: [.init(id: 1, cartId: 1, productId: 1, quantity: 2, product: .empty)]
  )

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
    #expect(sut.cart == nil)
    sut.viewDidAppear()

    // When
    mockCartSubject.send(mockCart)

    // Then
    let result = await sut.$cart.values.first(where: { $0?.isEmpty == false })
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
    #expect(sut.errorMessage != nil)
    #expect(sut.showAlert == true)
  }

  // MARK: - Remove Items

  @Test
  func removeItemsFromIndexSetSuccess() async throws {
    // Given
    sut.viewDidAppear()
    let mockCartWithMultipleItems = CartDTO(
      id: 1,
      cartItems: [
        .init(id: 1, cartId: 1, productId: 10, quantity: 2, product: .empty),
        .init(id: 2, cartId: 1, productId: 20, quantity: 1, product: .empty),
        .init(id: 3, cartId: 1, productId: 30, quantity: 3, product: .empty),
      ])
    mockCartSubject.send(mockCartWithMultipleItems)
    let currentCart = await sut.$cart.values.first { $0?.isEmpty == false }
    #expect(currentCart??.cartItems.count == 3)

    given(mockCartRepository)
      .removeFromCart(productId: .any)
      .willReturn()

    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)

    // When
    await sut.removeItemsFromIndexSet(IndexSet([0, 2]))

    // Then
    verify(mockCartRepository)
      .removeFromCart(productId: .value(10))
      .called(1)
    verify(mockCartRepository)
      .removeFromCart(productId: .value(30))
      .called(1)
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
  }

  @Test
  func removeItemsFromIndexSetFailure() async throws {
    // Given
    sut.viewDidAppear()
    let mockCartWithMultipleItems = CartDTO(
      id: 1,
      cartItems: [
        .init(id: 1, cartId: 1, productId: 10, quantity: 2, product: .empty),
        .init(id: 2, cartId: 1, productId: 20, quantity: 1, product: .empty),
      ])
    mockCartSubject.send(mockCartWithMultipleItems)
    let currentCart = await sut.$cart.values.first { $0?.isEmpty == false }
    #expect(currentCart??.cartItems.count == 2)

    given(mockCartRepository)
      .removeFromCart(productId: .any)
      .willThrow(NetworkError.invalidResponse)

    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)

    // When
    await sut.removeItemsFromIndexSet(IndexSet([0]))

    // Then
    #expect(sut.errorMessage != nil)
    #expect(sut.showAlert == true)
  }

  @Test
  func removeItemsFromIndexSetWithInvalidIndices() async throws {
    // Given
    sut.viewDidAppear()
    let mockCartWithMultipleItems = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 1, productId: 10, quantity: 2, product: .empty)]
    )
    mockCartSubject.send(mockCartWithMultipleItems)
    let currentCart = await sut.$cart.values.first { $0?.isEmpty == false }
    #expect(currentCart??.cartItems.count == 1)

    // When
    await sut.removeItemsFromIndexSet(IndexSet([1, 2]))  // Invalid indices

    // Then
    verify(mockCartRepository)
      .removeFromCart(productId: .any)
      .called(0)
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
  }
}
