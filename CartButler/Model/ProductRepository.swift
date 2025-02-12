//
//  ProductRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-11.
//
import Foundation

struct ProductDTO: Decodable, Equatable {
  let productId: Int
  let productName: String
  let description: String
  let price: Float
  let stock: Int
  let categoryId: Int
  let imagePath: String
  let createdAt: Date
}
