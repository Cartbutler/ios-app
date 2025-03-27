//
//  ProductRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-11.
//
import Foundation

struct ProductDTO: Decodable, Hashable, Identifiable {
  var id: Int { productId }

  let productId: Int
  let productName: String
  let description: String
  let price: Double?
  let stock: Int
  let categoryId: Int
  let imagePath: String
  let createdAt: Date
  let categoryName: String?
  let stores: [StoreDTO]?
  let minPrice: Double?
  let maxPrice: Double?

  var formattedPrice: String {
    Formatter.currency(from: minPrice, to: maxPrice)
  }
}

struct StoreDTO: Decodable, Hashable, Identifiable {
  var id: Int { storeId }
  let storeId: Int
  let price: Double
  let stock: Int
  let storeName: String
  let storeLocation: String
  let storeImage: String
}
