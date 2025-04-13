//
//  StoreFilterDTO.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-04-05.
//

import Foundation

struct StoreFilterDTO: Identifiable, Equatable {
  let id: Int
  let name: String
  let imagePath: String
  var isSelected: Bool
}
