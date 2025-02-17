//
//  ProductRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-11.
//
import Foundation

struct BasicProductDTO: Decodable, Equatable, Identifiable {
  var id: Int { productId }

  let productId: Int
  let productName: String
  let price: Float
  let imagePath: String
}

struct ProductDTO: Decodable, Equatable, Identifiable {
  var id: Int { productId }

  let productId: Int
  let productName: String
  let description: String
  let price: Float
  let stock: Int
  let categoryId: Int
  let imagePath: String
  let createdAt: Date
}

enum Formatter {
  static let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }()
  static func currency(from value: Float) -> String {
    currencyFormatter.string(from: NSNumber(value: value)) ?? ""
  }
}
