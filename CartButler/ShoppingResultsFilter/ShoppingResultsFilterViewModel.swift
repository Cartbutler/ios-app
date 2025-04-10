//
//  ShoppingResultsFilterViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class ShoppingResultsFilterViewModel: ObservableObject {
  let minRadius = 1.0
  let maxRadius = 10.0
  var radiusRange: ClosedRange<Double> {
    minRadius...maxRadius
  }

  @Published var showPermissionDeniedAlert = false
  @Published var showLocationUnavailableAlert = false
  @Published var selectedRadius: Double
  @Published var stores: [StoreFilterDTO]
  @Binding private var filterParameters: FilterParameters?
  private let locationService: LocationServiceProvider

  init(
    results: [ShoppingResultsDTO],
    filterParameters: Binding<FilterParameters?>,
    locationService: LocationServiceProvider = LocationService()
  ) {
    self._filterParameters = filterParameters
    self.locationService = locationService
    self.selectedRadius = filterParameters.wrappedValue?.distance ?? maxRadius
    self.stores = Self.mapStores(from: results, using: filterParameters.wrappedValue)
  }

  private static func mapStores(
    from results: [ShoppingResultsDTO],
    using filterParameters: FilterParameters?
  ) -> [StoreFilterDTO] {
    results.map { result in
      StoreFilterDTO(
        id: result.storeId,
        name: result.storeName,
        imagePath: result.storeImage,
        isSelected: filterParameters?.selectedStoreIds.contains(result.storeId) ?? true
      )
    }
  }

  func toggleStoreSelection(_ storeId: Int) {
    if let index = stores.firstIndex(where: { $0.id == storeId }) {
      stores[index].isSelected.toggle()
    }
  }

  func applyFilters() async -> Bool {
    do {
      let location = try await locationService.getCurrentLocation()
      filterParameters = FilterParameters(
        distance: selectedRadius,
        selectedStoreIds: Set(stores.filter(\.isSelected).map(\.id)),
        location: location
      )
      return true
    } catch LocationError.locationUnavailable {
      showLocationUnavailableAlert = true
    } catch {
      showPermissionDeniedAlert = true
    }
    return false
  }

  func clearFilters() {
    filterParameters = nil
  }
}
