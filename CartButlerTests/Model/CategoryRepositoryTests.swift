//
//  CategoryRepositoryTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-07.
//

import Foundation
import Mockable
import SwiftData
import Testing

@testable import CartButler

@MainActor
struct CategoryRepositoryTests {

  private let mockAPIService = MockAPIServiceProvider()
  private let mockContainer: ModelContainer
  private let sut: CategoryRepositoryImpl

  init() {
    let configuration = ModelConfiguration(for: Category.self, isStoredInMemoryOnly: true)
    mockContainer = try! ModelContainer(for: Category.self, configurations: configuration)

    sut = CategoryRepositoryImpl(
      apiService: mockAPIService,
      container: mockContainer
    )
  }

  @Test
  func fetchCategoriesSuccess() async throws {
    // Given
    let expectedResponse = [CategoryDTO(categoryId: 1, categoryName: "category")]
    given(mockAPIService)
      .fetchCategories()
      .willReturn(expectedResponse)
    let fetchDescriptor = FetchDescriptor<CartButler.Category>()
    let count = try mockContainer.mainContext.fetchCount(fetchDescriptor)
    try #require(count == 0)

    // When
    try await forContextSavedConfirmation {
      try await sut.fetchAll()
    }

    // Then
    let results = try mockContainer.mainContext.fetch(fetchDescriptor)
    #expect(results.count == 1)
    #expect(results.first?.id == 1)
    #expect(results.first?.name == "category")
  }

  @Test
  func fetchCategoriesFailure() async throws {
    // Given
    given(mockAPIService)
      .fetchCategories()
      .willThrow(NetworkError.invalidResponse)

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      try await sut.fetchAll()
    }
  }
}
