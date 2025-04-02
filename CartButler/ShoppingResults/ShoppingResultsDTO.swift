//
//  ShoppingResultsDTO.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//
import Foundation

struct ShoppingResultsDTO: Codable, Hashable, Identifiable {
  var id: Int { storeId }
  let storeId: Int
  let storeName: String
  let storeLocation: String
  let storeAddress: String
  let storeImage: String
  let products: [ProductDTO]
  let total: Double

  struct ProductDTO: Codable, Hashable, Identifiable {
    var id: Int { productId }
    let productId: Int
    let productName: String
    let price: Double
    let quantity: Int

    var total: Double {
      price * Double(quantity)
    }
  }
}
