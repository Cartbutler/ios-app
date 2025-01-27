//
//  HomeViewModelTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-26.
//
import SwiftData
import Testing
@testable import CartButler

@MainActor
struct HomeViewModelTests {
  
  private let container: ModelContainer
  private let sut: HomeViewModel
  
  init() async throws {
    container = try ModelContainer(
      for: Suggestion.self,
      configurations: .init(isStoredInMemoryOnly: true)
    )
    
    let context = ModelContext(container)
    context.insert(
      Suggestion(id: 1, searchKey: "key", suggestions: ["result"])
    )
    try context.save()
    
    sut = HomeViewModel(container: container)
  }
  
  @Test func initialSuggestionsShouldBeEmpty() async throws {
    // Given
    #expect(sut.searchKey == "")
    // Then
    #expect(sut.suggestions == [])
  }
  
  @Test func searchKeyShouldFetchItems() async throws {
    // Given
    #expect(sut.searchKey == "")
    // When
    sut.searchKey = "key"
    // Then
    #expect(sut.suggestions == ["result"])
  }
  
  @Test func noSuggestionsFound() async throws {
    // Given
    sut.searchKey = "key"
    #expect(sut.suggestions.count == 1)
    // When
    sut.searchKey = "unknown"
    // Then
    #expect(sut.suggestions == [])
  }
  
}


