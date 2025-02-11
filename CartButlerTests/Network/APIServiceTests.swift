//
//  APIServiceTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-05.
//

import Foundation
import Mockable
import Testing

@testable import CartButler

struct APIServiceTests {

  private let mockAPIClient = MockAPIClientProvider()
  private let sut: APIService

  init() {
    sut = APIService(apiClient: mockAPIClient)
  }

  // MARK: - Categories

  @Test
  func fetchCategoriesSuccess() async throws {
    // Given
    let expectedResponse = [CategoryDTO(categoryId: 1, categoryName: "category")]
    given(mockAPIClient)
      .get(path: .value("categories"), queryParameters: .value(nil))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchCategories()

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchCategoriesFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> [CategoryDTO] in
        throw NetworkError.invalidResponse
      }

    await #expect(throws: NetworkError.invalidResponse) {
      _ = try await sut.fetchCategories()
    }
  }

  // MARK: - Suggestions

  @Test
  func fetchSuggestionsSuccess() async throws {
    // Given
    let expectedResponse = [SuggestionDTO(id: 1, name: "suggestion", priority: 1)]
    given(mockAPIClient)
      .get(path: .value("suggestions"), queryParameters: .value(["query": "my query"]))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchSuggestions(query: "my query")

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchSuggestionsFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> [SuggestionDTO] in
        throw NetworkError.invalidResponse
      }

    await #expect(throws: NetworkError.invalidResponse) {
      _ = try await sut.fetchSuggestions(query: "my query")
    }
  }
}
