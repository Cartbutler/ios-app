//
//  Category.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-23.
//

import SwiftData

@Model
final class Category {
  @Attribute(.unique)
  var id: Int
  var name: String
  var icon: String

  init(id: Int, name: String, icon: String) {
    self.id = id
    self.name = name
    self.icon = icon
  }

  convenience init(dto: CategoryDTO) {
    self.init(id: dto.categoryId, name: dto.categoryName, icon: "❓")
  }
}
