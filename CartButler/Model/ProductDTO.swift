//
//  ProductRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-11.
//
import Foundation

struct BasicProductDTO: Decodable, Hashable, Identifiable {
  var id: Int { productId }

  let productId: Int
  let productName: String
  let price: Double
  let imagePath: String
}

struct ProductDTO: Decodable, Hashable, Identifiable {
  var id: Int { productId }

  let productId: Int
  let productName: String
  let description: String
  let price: Double
  let stock: Int
  let categoryId: Int
  let imagePath: String
  let createdAt: Date
  let categoryName: String?
  let productStore: [ProductStoreDTO]
}

struct ProductStoreDTO: Decodable, Hashable {
  let productStoreId: Int
  let productId: Int
  let storeId: Int
  //  let price: Double
  let stock: Int
  let stores: StoreDTO
}

struct StoreDTO: Decodable, Hashable {
  let storeId: Int
  let storeName: String
  let storeLocation: String
}

enum Formatter {
  static let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }()
  static func currency(from value: Double) -> String {
    currencyFormatter.string(from: NSNumber(value: value)) ?? ""
  }
}
