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
  private let mockAPIService = MockAPIServiceProvider()
  private let mockCartRepository = MockCartRepositoryProvider()
  private let mockCartSubject: CurrentValueSubject<CartDTO, Never>
  private let sut: ShoppingResultsViewModel

  private let cartDTO = CartDTO(
    cartItems: [.init(id: 1, cartId: 1, productId: 3, quantity: 4, product: .empty)]
  )

  private let cheapestResult = ShoppingResultsDTO(
    storeId: 1,
    storeName: "Cheapest Store",
    storeLocation: "Location 1",
    products: [],
    total: 10.99
  )

  private let otherResult1 = ShoppingResultsDTO(
    storeId: 2,
    storeName: "Medium Store",
    storeLocation: "Location 2",
    products: [],
    total: 12.99
  )

  private let otherResult2 =
    ShoppingResultsDTO(
      storeId: 3,
      storeName: "Expensive Store",
      storeLocation: "Location 3",
      products: [],
      total: 15.99
    )

  private let sortedShoppingResults: [ShoppingResultsDTO]
  private let otherResults: [ShoppingResultsDTO]

  init() {
    sut = ShoppingResultsViewModel(
      apiService: mockAPIService,
      cartRepository: mockCartRepository
    )
    sortedShoppingResults = [cheapestResult, otherResult1, otherResult2]
    otherResults = [otherResult1, otherResult2]
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
      .willReturn(sortedShoppingResults)
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
      .willReturn(sortedShoppingResults)

    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
    #expect(sut.cheapestResult == nil)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
    #expect(sut.cheapestResult == cheapestResult)
    #expect(sut.otherResults == otherResults)
  }

  @Test
  func fetchResultsFailureWithNetworkError() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .any)
      .willThrow(NetworkError.invalidResponse)

    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
    #expect(sut.cheapestResult == nil)
    #expect(sut.otherResults == nil)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.errorMessage != nil)
    #expect(sut.showAlert == true)
    #expect(sut.cheapestResult == nil)
    #expect(sut.otherResults == nil)
  }

  @Test
  func fetchResultsFailureWithEmptyCart() async throws {
    // Given
    mockCartSubject.send(CartDTO.empty)
    #expect(sut.errorMessage == nil)
    #expect(sut.showAlert == false)
    #expect(sut.cheapestResult == nil)
    #expect(sut.otherResults == nil)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.errorMessage == "No items in cart")
    #expect(sut.showAlert == true)
    #expect(sut.cheapestResult == nil)
    #expect(sut.otherResults == nil)
    verify(mockAPIService)
      .fetchShoppingResults(cartId: .any)
      .called(0)
  }

  @Test
  func fetchResultsShouldNotCallAPIIfAlreadyLoaded() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .willReturn(sortedShoppingResults)

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
      .willReturn(sortedShoppingResults)

    // When
    async let firstCall: () = sut.fetchResults()
    async let secondCall: () = sut.fetchResults()
    _ = await (firstCall, secondCall)

    // Then
    verify(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .called(1)  // Should only be called once
  }

  // MARK: - Cheapest Result Tests

  @Test
  func fetchResultsShouldSeparateCheapestResult() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .willReturn(sortedShoppingResults)

    #expect(sut.cheapestResult == nil)
    #expect(sut.otherResults == nil)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.cheapestResult?.storeId == 1)
    #expect(sut.cheapestResult?.total == 10.99)
    #expect(sut.otherResults?.count == 2)
    #expect(sut.otherResults?.first?.storeId == 2)
    #expect(sut.otherResults?.last?.storeId == 3)
  }

  @Test
  func fetchResultsWithSingleResultShouldHaveNoCheapestResult() async throws {
    // Given
    let singleResult = [cheapestResult]
    given(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .willReturn(singleResult)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.cheapestResult?.storeId == 1)
    #expect(sut.otherResults == [])
  }

  @Test
  func fetchResultsWithEmptyResultsShouldHaveNoResults() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .value(1))
      .willReturn([])

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.cheapestResult == nil)
    #expect(sut.otherResults == nil)
  }

  @Test
  func fetchResultsFailureShouldClearBothResults() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .any)
      .willThrow(NetworkError.invalidResponse)

    #expect(sut.cheapestResult == nil)
    #expect(sut.otherResults == nil)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.cheapestResult == nil)
    #expect(sut.otherResults == nil)
    #expect(sut.errorMessage != nil)
    #expect(sut.showAlert == true)
  }
}
