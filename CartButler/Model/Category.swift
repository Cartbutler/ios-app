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
  var imagePath: String

  init(id: Int, name: String, imagePath: String) {
    self.id = id
    self.name = name
    self.imagePath = imagePath
  }

  convenience init(dto: CategoryDTO) {
    self.init(id: dto.categoryId, name: dto.categoryName, imagePath: dto.imagePath)
  }
}
