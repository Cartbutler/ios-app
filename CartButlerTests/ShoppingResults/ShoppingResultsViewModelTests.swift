//
//  ShoppingResultsViewModelTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Combine
import CoreLocation
import Foundation
import Mockable
import Testing

@testable import CartButler

@MainActor
struct ShoppingResultsViewModelTests {
  private let mockAPIService = MockAPIServiceProvider()
  private let mockCartRepository = MockCartRepositoryProvider()
  private let mockCartSubject: CurrentValueSubject<CartDTO?, Never>
  private let sut: ShoppingResultsViewModel

  private let cartDTO = CartDTO(
    id: 1,
    cartItems: [.init(id: 1, cartId: 1, productId: 3, quantity: 4, product: .empty)]
  )

  private let cheapestResult = ShoppingResultsDTO(
    storeId: 1,
    storeName: "Cheapest Store",
    storeLocation: "Location 1",
    storeAddress: "Address 1",
    storeImage: "",
    products: [],
    total: 10.99
  )

  private let otherResult1 = ShoppingResultsDTO(
    storeId: 2,
    storeName: "Medium Store",
    storeLocation: "Location 2",
    storeAddress: "Address 2",
    storeImage: "",
    products: [],
    total: 12.99
  )

  private let otherResult2 = ShoppingResultsDTO(
    storeId: 3,
    storeName: "Expensive Store",
    storeLocation: "Location 3",
    storeAddress: "Address 3",
    storeImage: "",
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
    mockCartSubject = CurrentValueSubject<CartDTO?, Never>(cartDTO)
    given(mockCartRepository)
      .cartPublisher
      .willReturn(mockCartSubject.eraseToAnyPublisher())
  }

  // MARK: - State Tests

  @Test
  func fetchResultsShouldSetLoadingState() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .any, storeIds: .any, radius: .any, lat: .any, long: .any)
      .willReturn(sortedShoppingResults)
    #expect(sut.state == .idle)

    await confirmation { loadStarted in
      let subscription = sut.$state.sink { state in
        // Then
        if case .loading = state {
          loadStarted.confirm()
        }
      }
      // When
      await sut.fetchResults()
      subscription.cancel()
    }

    // Then
    if case .loaded(let result) = sut.state {
      #expect(result == cheapestResult)
    } else {
      Issue.record("Expected loaded state")
    }
  }

  // MARK: - Fetching results

  @Test
  func fetchResultsSuccess() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(sortedShoppingResults)

    #expect(sut.state == .idle)
    #expect(sut.showAlert == false)

    // When
    await sut.fetchResults()

    // Then
    if case .loaded(let result) = sut.state {
      #expect(result == cheapestResult)
    } else {
      Issue.record("Expected loaded state")
    }
    #expect(sut.showAlert == false)
    #expect(sut.allResults == sortedShoppingResults)
    #expect(sut.otherResults == otherResults)
  }

  @Test
  func fetchResultsFailureWithNetworkError() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .any, storeIds: .any, radius: .any, lat: .any, long: .any)
      .willThrow(NetworkError.invalidResponse)

    #expect(sut.state == .idle)
    #expect(sut.showAlert == false)
    #expect(sut.otherResults == [])

    // When
    await sut.fetchResults()

    // Then
    if case .error(let message) = sut.state {
      #expect(message.contains("Failed to load shopping results"))
    } else {
      Issue.record("Expected loaded state")
    }
    #expect(sut.showAlert == true)
    #expect(sut.allResults == [])
    #expect(sut.otherResults == [])
  }

  @Test
  func fetchResultsFailureWithEmptyCart() async throws {
    // Given
    mockCartSubject.send(nil)
    #expect(sut.state == .idle)
    #expect(sut.showAlert == false)
    #expect(sut.otherResults == [])

    // When
    await sut.fetchResults()

    // Then
    if case .error(let message) = sut.state {
      #expect(message == "No items in cart")
    } else {
      Issue.record("Expected loaded state")
    }
    #expect(sut.showAlert == true)
    #expect(sut.allResults == [])
    #expect(sut.otherResults == [])
    verify(mockAPIService)
      .fetchShoppingResults(cartId: .any, storeIds: .any, radius: .any, lat: .any, long: .any)
      .called(0)
  }

  @Test
  func fetchResultsShouldNotCallAPIIfNotIdle() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(sortedShoppingResults)

    // When
    await sut.fetchResults()  // First call sets state to .loaded
    await sut.fetchResults()  // Second call should not call API

    // Then
    verify(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .called(1)  // Should only be called once
  }

  @Test
  func fetchResultsShouldNotCallAPIIfLoading() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(sortedShoppingResults)

    // When
    async let firstCall: () = sut.fetchResults()
    async let secondCall: () = sut.fetchResults()
    _ = await (firstCall, secondCall)

    // Then
    verify(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .called(1)  // Should only be called once
  }

  // MARK: - Results Tests

  @Test
  func fetchResultsShouldSeparateResults() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(sortedShoppingResults)

    #expect(sut.allResults == [])
    #expect(sut.otherResults == [])

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.allResults == sortedShoppingResults)
    #expect(sut.otherResults.count == 2)
    #expect(sut.otherResults.first?.storeId == 2)
    #expect(sut.otherResults.last?.storeId == 3)
    if case .loaded(let result) = sut.state {
      #expect(result.storeId == 1)
      #expect(result.total == 10.99)
    } else {
      Issue.record("Expected loaded state")
    }
  }

  @Test
  func fetchResultsWithSingleResultShouldSetLoadedState() async throws {
    // Given
    let singleResult = [cheapestResult]
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(singleResult)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.allResults == singleResult)
    #expect(sut.otherResults == [])
    if case .loaded(let result) = sut.state {
      #expect(result.storeId == 1)
      #expect(result.total == 10.99)
    } else {
      Issue.record("Expected loaded state")
    }
  }

  @Test
  func fetchResultsWithEmptyResultsShouldSetEmptyState() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn([])

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.allResults == [])
    #expect(sut.otherResults == [])
    #expect(sut.state == .empty)
  }

  @Test
  func fetchResultsFailureShouldClearBothResults() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(cartId: .any, storeIds: .any, radius: .any, lat: .any, long: .any)
      .willThrow(NetworkError.invalidResponse)

    #expect(sut.allResults == [])
    #expect(sut.otherResults == [])

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.allResults == [])
    #expect(sut.otherResults == [])
    if case .error(let message) = sut.state {
      #expect(message.contains("Failed to load shopping results"))
    } else {
      Issue.record("Expected loaded state")
    }
    #expect(sut.showAlert == true)
  }

  @Test
  func fetchResultsWithFilterParameters() async throws {
    // Given
    let filterParameters = FilterParameters(
      distance: 5.0,
      selectedStoreIds: [1],
      location: CLLocation(latitude: 10, longitude: 20)
    )

    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value([1]),
        radius: .value(5.0),
        lat: .value(10),
        long: .value(20)
      )
      .willReturn(sortedShoppingResults)

    // When
    sut.filterParameters = filterParameters
    await sut.fetchResults()

    // Then
    if case .loaded(let result) = sut.state {
      #expect(result == cheapestResult)
    } else {
      Issue.record("Expected loaded state")
    }
    #expect(sut.allResults == sortedShoppingResults)
    #expect(sut.otherResults == otherResults)
  }

  @Test
  func changingFilterParametersShouldRefetch() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(sortedShoppingResults)
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value([1]),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(otherResults)

    await sut.fetchResults()  // First fetch
    #expect(sut.state == .loaded(cheapestResult))

    // When
    sut.filterParameters = FilterParameters(distance: 1, selectedStoreIds: [1], location: nil)
    _ = await sut.$state.values.first { $0 == .loading }

    // Then
    let result = await sut.$state.values.first {
      if case .loaded = $0 { return true } else { return false }
    }
    #expect(result == .loaded(otherResult1))
  }

  @Test
  func hasFiltersShouldReturnFalseWhenNoFilters() {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .any,
        storeIds: .any,
        radius: .any,
        lat: .any,
        long: .any
      )
      .willReturn([])
    sut.filterParameters = nil

    // Then
    #expect(sut.hasFilters == false)
  }

  @Test
  func hasFiltersShouldReturnTrueWhenFiltersAreSet() {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .any,
        storeIds: .any,
        radius: .any,
        lat: .any,
        long: .any
      )
      .willReturn([])
    let filterParameters = FilterParameters(
      distance: 5.0,
      selectedStoreIds: [1],
      location: CLLocation(latitude: 10, longitude: 20)
    )

    // When
    sut.filterParameters = filterParameters

    // Then
    #expect(sut.hasFilters == true)
  }

  @Test
  func isFilterAvailableShouldReturnFalseWhenNoResultsAndNoFilters() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn([])

    sut.filterParameters = nil

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.isFilterAvailable == false)
  }

  @Test
  func isFilterAvailableShouldReturnTrueWhenMultipleResults() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(sortedShoppingResults)

    sut.filterParameters = nil

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.isFilterAvailable == true)
  }

  @Test
  func isFilterAvailableShouldReturnTrueWhenFiltersAreSet() {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .any,
        storeIds: .any,
        radius: .any,
        lat: .any,
        long: .any
      )
      .willReturn([])
    let filterParameters = FilterParameters(
      distance: 5.0,
      selectedStoreIds: [1],
      location: CLLocation(latitude: 10, longitude: 20)
    )

    // When
    sut.filterParameters = filterParameters

    // Then
    #expect(sut.isFilterAvailable == true)
  }

  // MARK: - Available Stores Tests

  @Test
  func availableStoresShouldBeEmptyInitially() {
    // Then
    #expect(sut.availableStores.isEmpty)
  }

  @Test
  func availableStoresShouldBeSetAfterFirstFetch() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(sortedShoppingResults)

    #expect(sut.availableStores.isEmpty)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.availableStores.count == 3)
    #expect(sut.availableStores[0].id == 1)
    #expect(sut.availableStores[0].name == "Cheapest Store")
    #expect(sut.availableStores[0].isSelected)
    #expect(sut.availableStores[1].id == 2)
    #expect(sut.availableStores[1].name == "Medium Store")
    #expect(sut.availableStores[1].isSelected)
    #expect(sut.availableStores[2].id == 3)
    #expect(sut.availableStores[2].name == "Expensive Store")
    #expect(sut.availableStores[2].isSelected)
  }

  @Test
  func availableStoresShouldNotBeUpdatedOnSubsequentFetches() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn(sortedShoppingResults)

    // When
    await sut.fetchResults()  // First fetch
    let firstAvailableStores = sut.availableStores
    await sut.fetchResults()  // Second fetch

    // Then
    #expect(sut.availableStores == firstAvailableStores)
  }

  @Test
  func availableStoresShouldBeEmptyWhenNoResults() async throws {
    // Given
    given(mockAPIService)
      .fetchShoppingResults(
        cartId: .value(1),
        storeIds: .value(nil),
        radius: .value(nil),
        lat: .value(nil),
        long: .value(nil)
      )
      .willReturn([])

    #expect(sut.availableStores.isEmpty)

    // When
    await sut.fetchResults()

    // Then
    #expect(sut.availableStores.isEmpty)
  }
}
