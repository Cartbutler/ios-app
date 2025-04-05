//
//  FilterParameters.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import Foundation

struct FilterParameters: Equatable {
  var distance: Double?
  var selectedStoreIds: Set<Int>?
}
