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
  @Published var showCompleteOnly = false
  @Binding private var filterParameters: FilterParameters?
  private let locationService: LocationServiceProvider

  init(
    stores: [StoreFilterDTO],
    filterParameters: Binding<FilterParameters?>,
    locationService: LocationServiceProvider = LocationService()
  ) {
    self._filterParameters = filterParameters
    self.locationService = locationService
    self.selectedRadius = filterParameters.wrappedValue?.distance ?? maxRadius
    self.stores = Self.mapStores(from: stores, using: filterParameters.wrappedValue)
  }

  private static func mapStores(
    from stores: [StoreFilterDTO],
    using filterParameters: FilterParameters?
  ) -> [StoreFilterDTO] {
    stores.map { store in
      StoreFilterDTO(
        id: store.id,
        name: store.name,
        imagePath: store.imagePath,
        isSelected: filterParameters?.selectedStoreIds.contains(store.id) ?? true
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
      try await locationService.getCurrentLocation()
      filterParameters = FilterParameters(
        distance: selectedRadius,
        selectedStoreIds: Set(stores.filter(\.isSelected).map(\.id)),
        showCompleteOnly: showCompleteOnly
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
