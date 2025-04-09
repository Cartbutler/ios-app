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
  private let mockLocation = CLLocation(latitude: 10, longitude: 20)

  // MARK: - Initialization Tests

  @Test
  func initWithAllParametersShouldSetValuesCorrectly() {
    // Given
    let distance = 5.0
    let storeIds: Set<Int> = [1, 2, 3]

    // When
    let sut = FilterParameters(
      distance: distance,
      selectedStoreIds: storeIds,
      location: mockLocation
    )

    // Then
    #expect(sut.distance == distance)
    #expect(sut.selectedStoreIds == storeIds)
    #expect(sut.location == mockLocation)
  }

  @Test
  func initWithNoLocationShouldSetValuesCorrectly() {
    // Given
    let distance = 5.0
    let storeIds: Set<Int> = [1, 2, 3]

    // When
    let sut = FilterParameters(
      distance: distance,
      selectedStoreIds: storeIds,
      location: nil
    )

    // Then
    #expect(sut.distance == distance)
    #expect(sut.selectedStoreIds == storeIds)
    #expect(sut.location == nil)
  }

  // MARK: - Computed Properties Tests

  @Test
  func storeIdsShouldReturnArrayOfSelectedStoreIds() {
    // Given
    let storeIds: Set<Int> = [1, 2, 3]
    let sut = FilterParameters(
      distance: 5.0,
      selectedStoreIds: storeIds,
      location: nil
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
      selectedStoreIds: [],
      location: mockLocation
    )

    // When
    let result = sut.radius

    // Then
    #expect(result == distance)
  }

  @Test
  func radiusShouldReturnNilWhenLocationIsNotAvailable() {
    // Given
    let sut = FilterParameters(
      distance: 5.0,
      selectedStoreIds: [],
      location: nil
    )

    // When
    let result = sut.radius

    // Then
    #expect(result == nil)
  }

  @Test
  func latitudeShouldReturnLocationLatitudeWhenAvailable() {
    // Given
    let sut = FilterParameters(
      distance: 5.0,
      selectedStoreIds: [],
      location: mockLocation
    )

    // When
    let result = sut.latitude

    // Then
    #expect(result == mockLocation.coordinate.latitude)
  }

  @Test
  func latitudeShouldReturnNilWhenLocationIsNotAvailable() {
    // Given
    let sut = FilterParameters(
      distance: 5.0,
      selectedStoreIds: [],
      location: nil
    )

    // When
    let result = sut.latitude

    // Then
    #expect(result == nil)
  }

  @Test
  func longitudeShouldReturnLocationLongitudeWhenAvailable() {
    // Given
    let sut = FilterParameters(
      distance: 5.0,
      selectedStoreIds: [],
      location: mockLocation
    )

    // When
    let result = sut.longitude

    // Then
    #expect(result == mockLocation.coordinate.longitude)
  }

  @Test
  func longitudeShouldReturnNilWhenLocationIsNotAvailable() {
    // Given
    let sut = FilterParameters(
      distance: 5.0,
      selectedStoreIds: [],
      location: nil
    )

    // When
    let result = sut.longitude

    // Then
    #expect(result == nil)
  }
}
