//
//  ShoppingResultsFilterViewModelTests.swift
//  CartButlerTests
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import CoreLocation
import Mockable
import SwiftUI
import Testing

@testable import CartButler

@MainActor
final class ShoppingResultsFilterViewModelTests {
  private var filterParameters: FilterParameters?
  private lazy var mockBinding = Binding<FilterParameters?>(
    get: { self.filterParameters },
    set: { self.filterParameters = $0 }
  )
  private let mockLocationService = MockLocationServiceProvider()
  private let mockLocation = CLLocation(latitude: 10, longitude: 20)

  // MARK: - Setup

  init() {
    given(mockLocationService)
      .getCurrentLocation()
      .willReturn(mockLocation)
  }

  // MARK: - Initialization Tests

  @Test
  func initWithNoFilterParametersWhouldSetDefaultValues() async {
    // Given
    let stores = [makeStore(id: 1), makeStore(id: 2)]

    // When
    let sut = ShoppingResultsFilterViewModel(
      stores: stores,
      filterParameters: mockBinding,
      locationService: mockLocationService
    )

    // Then
    #expect(sut.selectedRadius == sut.maxRadius)
    #expect(sut.stores.count == 2)
    #expect(sut.stores.allSatisfy { $0.isSelected })
  }

  @Test
  func initWithFilterParametersShouldSetValuesFromParameters() async {
    // Given
    let stores = [makeStore(id: 1), makeStore(id: 2)]
    filterParameters = FilterParameters(distance: 5.0, selectedStoreIds: [1], showCompleteOnly: false)

    // When
    let sut = ShoppingResultsFilterViewModel(
      stores: stores,
      filterParameters: mockBinding,
      locationService: mockLocationService
    )

    // Then
    #expect(sut.selectedRadius == 5.0)
    #expect(sut.stores.count == 2)
    #expect(sut.stores.filter(\.isSelected).count == 1)
    #expect(sut.stores.first(where: { $0.id == 1 })?.isSelected == true)
    #expect(sut.stores.first(where: { $0.id == 2 })?.isSelected == false)
  }

  // MARK: - Store Selection Tests

  @Test
  func toggleStoreSelectionShouldChangeSelectionValue() async {
    // Given
    let stores = [makeStore(id: 1)]
    let sut = ShoppingResultsFilterViewModel(
      stores: stores,
      filterParameters: mockBinding,
      locationService: mockLocationService
    )
    #expect(sut.stores.count == 1)
    #expect(sut.stores.first?.isSelected == true)

    // When
    sut.toggleStoreSelection(1)

    // Then
    #expect(sut.stores.first?.isSelected == false)
  }

  @Test
  func toggleStoreSelectionInvalidIdShouldNotChangeSelection() async {
    // Given
    let stores = [makeStore(id: 1)]
    let sut = ShoppingResultsFilterViewModel(
      stores: stores,
      filterParameters: mockBinding,
      locationService: mockLocationService
    )
    #expect(sut.stores.count == 1)
    #expect(sut.stores.first?.isSelected == true)

    // When
    sut.toggleStoreSelection(999)

    // Then
    #expect(sut.stores.first?.isSelected == true)
  }

  // MARK: - Location Tests

  @Test
  func applyFiltersShouldShowLocationUnavailableAlert() async {
    // Given
    mockLocationService.reset()
    given(mockLocationService)
      .getCurrentLocation()
      .willThrow(LocationError.locationUnavailable)
    let sut = ShoppingResultsFilterViewModel(
      stores: [],
      filterParameters: mockBinding,
      locationService: mockLocationService
    )

    // When
    let result = await sut.applyFilters()

    // Then
    #expect(result == false)
    #expect(sut.showLocationUnavailableAlert == true)
  }

  @Test
  func applyFiltersShouldShowPermissionDeniedAlert() async {
    // Given
    mockLocationService.reset()
    given(mockLocationService)
      .getCurrentLocation()
      .willThrow(LocationError.permissionDenied)
    let sut = ShoppingResultsFilterViewModel(
      stores: [],
      filterParameters: mockBinding,
      locationService: mockLocationService
    )

    // When
    let result = await sut.applyFilters()

    // Then
    #expect(result == false)
    #expect(sut.showPermissionDeniedAlert == true)
  }

  // MARK: - Filter Application Tests

  @Test
  func applyFiltersShouldUpdateFilterParameters() async {
    // Given
    let stores = [makeStore(id: 1), makeStore(id: 2)]
    let sut = ShoppingResultsFilterViewModel(
      stores: stores,
      filterParameters: mockBinding,
      locationService: mockLocationService
    )
    sut.selectedRadius = 3.0
    sut.toggleStoreSelection(1)

    // When
    let result = await sut.applyFilters()

    // Then
    #expect(result == true)
    #expect(filterParameters?.distance == 3.0)
    #expect(filterParameters?.selectedStoreIds == [2])
  }

  @Test
  func applyFiltersWithNoStoresSelectedWhouldUpdateFilterParameters() async {
    // Given
    let stores = [makeStore(id: 1), makeStore(id: 2)]
    let sut = ShoppingResultsFilterViewModel(
      stores: stores,
      filterParameters: mockBinding,
      locationService: mockLocationService
    )
    sut.selectedRadius = 3.0
    sut.toggleStoreSelection(1)
    sut.toggleStoreSelection(2)

    // When
    let result = await sut.applyFilters()

    // Then
    #expect(result == true)
    #expect(filterParameters?.distance == 3.0)
    #expect(filterParameters?.selectedStoreIds == [])
  }

  // MARK: - Clear Filters Tests

  @Test
  func clearFiltersShouldSetFilterParametersToNil() async {
    // Given
    let stores = [makeStore(id: 1)]
    let sut = ShoppingResultsFilterViewModel(
      stores: stores,
      filterParameters: mockBinding,
      locationService: mockLocationService
    )
    let result = await sut.applyFilters()
    #expect(result == true)
    #expect(filterParameters != nil)

    // When
    sut.clearFilters()

    // Then
    #expect(filterParameters == nil)
  }

  private func makeStore(id: Int) -> StoreFilterDTO {
    StoreFilterDTO(
      id: id,
      name: "Store\(id)",
      imagePath: "image\(id)",
      isSelected: true
    )
  }
}
