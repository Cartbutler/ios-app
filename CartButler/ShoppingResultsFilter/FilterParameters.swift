//
//  FilterParameters.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import CoreLocation
import Foundation

struct FilterParameters {
  let distance: Double
  let selectedStoreIds: Set<Int>
  let location: CLLocation?

  var storeIds: [Int] { Array(selectedStoreIds) }
  var radius: Double? { location != nil ? distance : nil }
  var latitude: Double? { location?.coordinate.latitude }
  var longitude: Double? { location?.coordinate.longitude }
}
