//
//  BasicProductDTO.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-15.
//
import Foundation

struct BasicProductDTO: Decodable, Hashable, Identifiable {
  var id: Int { productId }

  let productId: Int
  let productName: String
  let minPrice: Double
  let maxPrice: Double
  let imagePath: String
}
