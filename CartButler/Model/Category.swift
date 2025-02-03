//
//  Category.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-23.
//

import SwiftData

@Model
final class Category {
  var id: Int
  var name: String
  var icon: String

  init(id: Int, name: String, icon: String) {
    self.id = id
    self.name = name
    self.icon = icon
  }
}

extension Category: DataPreloader {
  static var defaults: [Category] {
    [
      Category(id: 1, name: "Dairy & Eggs", icon: "🥚"),
      Category(id: 2, name: "Bakery", icon: "🍞"),
      Category(id: 3, name: "Fruits & Vegetables", icon: "🍎"),
      Category(id: 4, name: "Snacks", icon: "🍿"),
      Category(id: 5, name: "Health", icon: "💊"),
      Category(id: 6, name: "Personal Care", icon: "🧼"),
      Category(id: 7, name: "Meat", icon: "🥩"),
      Category(id: 8, name: "Deli", icon: "🥪"),
      Category(id: 9, name: "Frozen", icon: "❄️"),
      Category(id: 10, name: "Fish & Seafood", icon: "🦞"),
      Category(id: 11, name: "Beverages", icon: "🥤"),
    ]
  }
}
