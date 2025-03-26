//
//  Formatter.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-25.
//

import Foundation

enum Formatter {
  static let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }()

  static func currency(with value: Double?) -> String {
    value.flatMap(NSNumber.init).flatMap(currencyFormatter.string) ?? ""
  }

  static func currency(from minPrice: Double?, to maxPrice: Double?) -> String {
    guard let minPrice, let maxPrice else { return "" }
    if minPrice == maxPrice {
      return currency(with: minPrice)
    } else {
      return "\(currency(with: minPrice)) - \(currency(with: maxPrice))"
    }
  }
}
