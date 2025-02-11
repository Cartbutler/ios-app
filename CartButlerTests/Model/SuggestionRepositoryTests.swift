//
//  SuggestionRepositoryTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-10.
//

import Foundation
import Mockable
import SwiftData
import Testing

@testable import CartButler

@MainActor
struct SuggestionRepositoryTests {

  private let mockAPIService = MockAPIServiceProvider()
  private let mockContainer: ModelContainer
  private let sut: SuggestionRepositoryImpl

  init() {
    let configuration = ModelConfiguration(for: SuggestionSet.self, isStoredInMemoryOnly: true)
    mockContainer = try! ModelContainer(for: SuggestionSet.self, configurations: configuration)
    sut = SuggestionRepositoryImpl(
      apiService: mockAPIService,
      container: mockContainer
    )
  }

  @Test
  func fetchSuggestionsSuccess() async throws {
    // Given
    let expectedResponse = [SuggestionDTO(id: 1, name: "suggestion", priority: 1)]
    given(mockAPIService)
      .fetchSuggestions(query: .value("query"))
      .willReturn(expectedResponse)

    let fetchDescriptor = FetchDescriptor<SuggestionSet>()
    let count = try mockContainer.mainContext.fetchCount(fetchDescriptor)
    try #require(count == 0)

    // When
    try await forContextSavedConfirmation {
      try await sut.fetchSuggestions(query: "query")
    }

    // Then
    let results = try mockContainer.mainContext.fetch(fetchDescriptor)
    #expect(results.count == 1)
    #expect(results.first?.query == "query")
    #expect(results.first?.suggestions.count == 1)
    #expect(results.first?.suggestions.first?.name == "suggestion")
    #expect(results.first?.suggestions.first?.priority == 1)
  }

  @Test
  func fetchSuggestionsFailure() async throws {
    // Given
    given(mockAPIService)
      .fetchSuggestions(query: .any)
      .willThrow(NetworkError.invalidResponse)

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      try await sut.fetchSuggestions(query: "query")
    }
  }
}
