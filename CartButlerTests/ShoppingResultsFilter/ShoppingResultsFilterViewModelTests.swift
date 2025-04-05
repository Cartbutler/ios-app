//
//  ShoppingResultsFilterViewModelTests.swift
//  CartButlerTests
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

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

  // MARK: - Initialization Tests

  @Test
  func initWithNoFilterParametersWhouldSetDefaultValues() async {
    // Given
    let results = [makeShoppingResult(id: 1), makeShoppingResult(id: 2)]

    // When
    let sut = ShoppingResultsFilterViewModel(results: results, filterParameters: mockBinding)

    // Then
    #expect(sut.selectedRadius == sut.maxRadius)
    #expect(sut.stores.count == 2)
    #expect(sut.stores.allSatisfy { $0.isSelected })
  }

  @Test
  func initWithFilterParametersShouldSetValuesFromParameters() async {
    // Given
    let results = [makeShoppingResult(id: 1), makeShoppingResult(id: 2)]
    filterParameters = FilterParameters(distance: 5.0, selectedStoreIds: [1])

    // When
    let sut = ShoppingResultsFilterViewModel(results: results, filterParameters: mockBinding)

    // Then
    #expect(sut.selectedRadius == 5.0)
    #expect(sut.stores.count == 2)
    #expect(sut.stores.filter(\.isSelected).count == 1)
    #expect(sut.stores.first(where: { $0.id == 1 })?.isSelected == true)
    #expect(sut.stores.first(where: { $0.id == 2 })?.isSelected == false)
  }

  // MARK: - Store Selection Tests

  @Test
  func ttoggleStoreSelectionShouldChangeSelectionValue() async {
    // Given
    let results = [makeShoppingResult(id: 1)]
    let sut = ShoppingResultsFilterViewModel(results: results, filterParameters: mockBinding)
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
    let results = [makeShoppingResult(id: 1)]
    let sut = ShoppingResultsFilterViewModel(results: results, filterParameters: mockBinding)
    #expect(sut.stores.count == 1)
    #expect(sut.stores.first?.isSelected == true)

    // When
    sut.toggleStoreSelection(999)

    // Then
    #expect(sut.stores.first?.isSelected == true)
  }

  // MARK: - Filter Application Tests

  @Test
  func applyFiltersShouldUpdateFilterParameters() async {
    // Given
    let results = [makeShoppingResult(id: 1), makeShoppingResult(id: 2)]
    let sut = ShoppingResultsFilterViewModel(results: results, filterParameters: mockBinding)
    sut.selectedRadius = 3.0
    sut.toggleStoreSelection(1)

    // When
    sut.applyFilters()

    // Then
    #expect(filterParameters?.distance == 3.0)
    #expect(filterParameters?.selectedStoreIds == [2])
  }

  @Test
  func applyFiltersWithNoStoresSelectedWhouldUpdateFilterParameters() async {
    // Given
    let results = [makeShoppingResult(id: 1), makeShoppingResult(id: 2)]
    let sut = ShoppingResultsFilterViewModel(results: results, filterParameters: mockBinding)
    sut.selectedRadius = 3.0
    sut.toggleStoreSelection(1)
    sut.toggleStoreSelection(2)

    // When
    sut.applyFilters()

    // Then
    #expect(filterParameters?.distance == 3.0)
    #expect(filterParameters?.selectedStoreIds == [])
  }

  // MARK: - Clear Filters Tests

  @Test
  func clearFiltersShouldSetFilterParametersToNil() async {
    // Given
    let results = [makeShoppingResult(id: 1)]
    let sut = ShoppingResultsFilterViewModel(results: results, filterParameters: mockBinding)
    sut.applyFilters()
    #expect(filterParameters != nil)

    // When
    sut.clearFilters()

    // Then
    #expect(filterParameters == nil)
  }

  private func makeShoppingResult(id: Int) -> ShoppingResultsDTO {
    ShoppingResultsDTO(
      storeId: id,
      storeName: "Store\(id)",
      storeLocation: "image\(id)",
      storeAddress: "",
      storeImage: "",
      products: [],
      total: 0.0
    )
  }
}
