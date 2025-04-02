//
//  StoreLocator.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-04-01.
//
import MapKit

extension MKMapItem: @unchecked @retroactive Sendable {}

final class StoreLocator {
  static func search(_ store: ShoppingResultsDTO) async throws -> MKMapItem {
    try await withCheckedThrowingContinuation { continuation in

      let searchRequest = MKLocalSearch.Request()
      searchRequest.naturalLanguageQuery =
        "\(store.storeName) \(store.storeLocation) \(store.storeAddress)"
      searchRequest.resultTypes = .pointOfInterest

      let search = MKLocalSearch(request: searchRequest)
      search.start { response, error in
        if let error {
          continuation.resume(throwing: error)
        }
        guard let item = response?.mapItems.first else {
          continuation.resume(throwing: NetworkError.invalidResponse)
          return
        }
        continuation.resume(returning: item)
      }
    }
  }

  static func openMapsDirections(to destination: MKMapItem) {
    let source = MKMapItem.forCurrentLocation()
    let launchOptions = [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ]
    MKMapItem.openMaps(with: [source, destination], launchOptions: launchOptions)
  }
}
