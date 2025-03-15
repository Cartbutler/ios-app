//
//  SearchViewModelTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-26.
//
import Mockable
import Testing

@testable import CartButler

@MainActor
struct SearchViewModelTests {

  private let mockCategoryRepository = MockCategoryRepository()
  private let mockSuggestionRepository = MockSuggestionRepository()
  private let sut: SearchViewModel

  init() async throws {
    sut = SearchViewModel(
      categoryRepository: mockCategoryRepository,
      suggestionRepository: mockSuggestionRepository
    )

    given(mockCategoryRepository)
      .fetchAll()
      .willReturn()
    given(mockSuggestionRepository)
      .fetchSuggestions(query: .any)
      .willReturn()
  }

  // MARK: - Categories

  @Test
  func fetchCategoriesShouldCallRepository() async {
    // When
    sut.fetchCategories()

    // Then
    await verify(mockCategoryRepository)
      .fetchAll()
      .calledEventually(1)
  }

  @Test
  func fetchCategoriesFailureShouldNotThrow() async {
    // Given
    let error = NetworkError.invalidResponse
    given(mockCategoryRepository)
      .fetchAll()
      .willThrow(error)

    // Then
    #expect(throws: Never.self) {
      // When
      sut.fetchCategories()
    }
  }

  // MARK: - Suggestions

  @Test func searchKeyShouldFetchSuggestions() async throws {
    // Given
    #expect(sut.searchKey == "")
    #expect(sut.query == "")

    // When
    sut.searchKey = " Some key "

    // Then
    #expect(sut.query == "some key")
    await verify(mockSuggestionRepository)
      .fetchSuggestions(query: .value("some key"))
      .calledEventually(1)
  }

  @Test
  func suggestionsFailureShouldNotThrow() async {
    // Given
    let error = NetworkError.invalidResponse
    given(mockSuggestionRepository)
      .fetchSuggestions(query: .any)
      .willThrow(error)

    // Then
    #expect(throws: Never.self) {
      // When
      sut.searchKey = "key"
    }
  }

}
