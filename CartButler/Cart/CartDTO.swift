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

struct CartDTO: Decodable, Hashable, Identifiable {
  let id: Int
  let cartItems: [CartItemDTO]

  /// Returns true if there are no elements in the ``cartItems`` array
  var isEmpty: Bool { cartItems.isEmpty }
  
  /// Returns the quantity of a specific product in the cart
  /// - Parameter productId: The ID of the product to find
  /// - Returns: The quantity of the product in the cart, or 0 if not found
  func quantity(for productId: Int) -> Int {
    cartItems.first { $0.productId == productId }?.quantity ?? 0
  }
  
  /// Checks if a product is in the cart
  /// - Parameter productId: The ID of the product to check
  /// - Returns: True if the product is in the cart, false otherwise
  func contains(productId: Int) -> Bool {
    cartItems.contains { $0.productId == productId }
  }
  
  /// Returns the cart item for a specific product
  /// - Parameter productId: The ID of the product to find
  /// - Returns: The CartItemDTO if found, nil otherwise
  func item(for productId: Int) -> CartItemDTO? {
    cartItems.first { $0.productId == productId }
  }
  
  /// Returns the total quantity of all items in the cart
  var totalQuantity: Int {
    cartItems.reduce(0) { $0 + $1.quantity }
  }
}

struct CartItemDTO: Decodable, Identifiable, Hashable {
  let id: Int
  let cartId: Int
  let productId: Int
  let quantity: Int
  let product: ProductDTO

  enum CodingKeys: String, CodingKey {
    case id
    case cartId
    case productId
    case quantity
    case product = "products"
  }
}
