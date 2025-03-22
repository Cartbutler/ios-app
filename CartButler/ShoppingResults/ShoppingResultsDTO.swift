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
  let products: [ProductDTO]
  let total: Double

  struct ProductDTO: Codable, Hashable, Identifiable {
    let id = UUID().uuidString
    let productName: String
    let price: Double
    let quantity: Int

    var total: Double {
      price * Double(quantity)
    }
  }
}
