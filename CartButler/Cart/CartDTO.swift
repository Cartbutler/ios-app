//
//  CartDTO.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-02.
//

import Foundation

struct AddToCartDTO: Encodable {
  let userId: String
  let productId: Int
  let quantity: Int
}

struct CartDTO: Decodable, Identifiable, Hashable {
  let id: Int
  let userId: String
  let productId: Int
  let quantity: Int
}
