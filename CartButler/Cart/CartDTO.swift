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

struct CartDTO: Decodable, Hashable {
  let cartItems: [CartItemDTO]

  static let empty = CartDTO(cartItems: [])

  var isEmpty: Bool { cartItems.isEmpty }
}

struct CartItemDTO: Decodable, Identifiable, Hashable {
  let id: Int
  let cartId: Int
  let productId: Int
  let quantity: Int
}
