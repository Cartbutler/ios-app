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
}
