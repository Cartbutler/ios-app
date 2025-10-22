//
//  FilterParameters.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import Foundation

struct FilterParameters: Hashable {
  let distance: Double
  let selectedStoreIds: Set<Int>
  let showCompleteOnly: Bool

  var storeIds: [Int] { Array(selectedStoreIds) }
  var radius: Double? { distance }
}
