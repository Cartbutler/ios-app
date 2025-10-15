//
//  FilterParametersTests.swift
//  CartButlerTests
//
//  Created by Cassiano Monteiro on 2025-04-09.
//

import CoreLocation
import Testing

@testable import CartButler

final class FilterParametersTests {

  // MARK: - Initialization Tests

  @Test
  func initWithAllParametersShouldSetValuesCorrectly() {
    // Given
    let distance = 5.0
    let storeIds: Set<Int> = [1, 2, 3]

    // When
    let sut = FilterParameters(
      distance: distance,
      selectedStoreIds: storeIds
    )

    // Then
    #expect(sut.distance == distance)
    #expect(sut.selectedStoreIds == storeIds)
  }

  @Test
  func initWithNoLocationShouldSetValuesCorrectly() {
    // Given
    let distance = 5.0
    let storeIds: Set<Int> = [1, 2, 3]

    // When
    let sut = FilterParameters(
      distance: distance,
      selectedStoreIds: storeIds
    )

    // Then
    #expect(sut.distance == distance)
    #expect(sut.selectedStoreIds == storeIds)
  }

  // MARK: - Computed Properties Tests

  @Test
  func storeIdsShouldReturnArrayOfSelectedStoreIds() {
    // Given
    let storeIds: Set<Int> = [1, 2, 3]
    let sut = FilterParameters(
      distance: 5.0,
      selectedStoreIds: storeIds
    )

    // When
    let result = sut.storeIds

    // Then
    #expect(result.count == 3)
    #expect(result.contains(1))
    #expect(result.contains(2))
    #expect(result.contains(3))
  }

  @Test
  func radiusShouldReturnDistanceWhenLocationIsAvailable() {
    // Given
    let distance = 5.0
    let sut = FilterParameters(
      distance: distance,
      selectedStoreIds: []
    )

    // When
    let result = sut.radius

    // Then
    #expect(result == distance)
  }
}
