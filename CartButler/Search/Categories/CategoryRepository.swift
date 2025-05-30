//
//  CategoryRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-05.
//

import Foundation
import Mockable
import SwiftData

struct CategoryDTO: Decodable, Equatable {
  let categoryId: Int
  let categoryName: String
  let imagePath: String
}

@Mockable
protocol CategoryRepository: Sendable {
  func fetchAll() async throws
}

@MainActor
final class CategoryRepositoryImpl: CategoryRepository {
  private let apiService: APIServiceProvider
  private let container: ModelContainer

  init(
    apiService: APIServiceProvider = APIService.shared,
    container: ModelContainer = MainContainer.shared
  ) {
    self.apiService = apiService
    self.container = container
  }

  func fetchAll() async throws {
    let categories = try await apiService.fetchCategories()
    Task {
      let context = container.newBackgroundContext()
      try context.transaction {
        try context.delete(model: Category.self)
        categories.forEach { context.insert(Category(dto: $0)) }
      }
    }
  }
}
