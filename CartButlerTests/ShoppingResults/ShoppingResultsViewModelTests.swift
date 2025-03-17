//
//  ShoppingResultsViewModelTests.swift
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
struct ShoppingResultsViewModelTests {

  private let shoppingResults = [
    ShoppingResultsDTO(
      storeId: 1,
      storeName: "Store 1",
      storeLocation: "Location 1",
      products: [],
      total: 10.99
    ),
    ShoppingResultsDTO(
      storeId: 2,
      storeName: "Store 2",
      storeLocation: "Location 2",
      products: [],
      total: 12.99
    ),
  ]

  private let cartDTO = CartDTO(
    cartItems: [.init(id: 1, cartId: 1, productId: 3, quantity: 4, product: .empty)]
  )

  private let mockAPIService = MockAPIServiceProvider()
  private let mockCartRepository = MockCartRepositoryProvider()
  private let mockCartSubject: CurrentValueSubject<CartDTO, Never>
  private let sut: ShoppingResultsViewModel

  init() {
    sut = ShoppingResultsViewModel(
      apiService: mockAPIService,
      cartRepository: mockCartRepository
    )
    mockCartSubject = CurrentValueSubject<CartDTO, Never>(cartDTO)
    given(mockCartRepository)
      .cartPublisher
      .willReturn(mockCartSubject.eraseToAnyPublisher())
  }

  // MARK: - Loading state

  @Test
  func fetchResultsShouldSetLoadingState() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .any)
      .willReturn(shoppingResults)
    #expect(sut.isLoading == false)

    await confirmation { loadStarted in
      let subscription = sut.$isLoading.sink { isLoading in
        // Then
        if isLoading {
          loadStarted.confirm()
        }
      }
      // When
      await sut.fetchResults()
      subscription.cancel()
    }

    // Then
    #expect(sut.isLoading == false)
  }

  // MARK: - Fetching results

  @Test
  func fetchResultsSuccess() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .willReturn(shoppingResults)

    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
    #expect(sut.results == nil)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
    #expect(sut.results == shoppingResults)
  }

  @Test
  func fetchResultsFailureWithNetworkError() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .any)
      .willThrow(NetworkError.invalidResponse)

    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
    #expect(sut.results == nil)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.errorMessage != nil)
    #expect(sut.showAlert == true)
    #expect(sut.results == nil)
  }

  @Test
  func fetchResultsFailureWithEmptyCart() async throws {
    // Given
    mockCartSubject.send(CartDTO.empty)
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
    #expect(sut.results == nil)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.errorMessage == "No items in cart")
    #expect(sut.showAlert == true)
    #expect(sut.results == nil)
    verify(mockAPIService)
      .fetchShoppingResults(cartId: .any)
      .called(0)
  }

  @Test
  func fetchResultsShouldNotCallAPIIfAlreadyLoaded() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .willReturn(shoppingResults)

    // When
    await sut.fetchResults()  // First call
    await sut.fetchResults()  // Second call

    // Then
    verify(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .called(1)  // Should only be called once
  }

  @Test
  func fetchResultsShouldNotCallAPIIfLoading() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .willReturn(shoppingResults)

    // When
    async let firstCall = sut.fetchResults()
    async let secondCall = sut.fetchResults()
    await [firstCall, secondCall]

    // Then
    verify(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .called(1)  // Should only be called once
  }
}
