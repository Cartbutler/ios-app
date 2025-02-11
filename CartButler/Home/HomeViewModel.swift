//
//  HomeViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-25.
//
import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

  private let categoryRepository: CategoryRepository
  private let suggestionRepository: SuggestionRepository

  @Published var searchKey = "" {
    didSet {
      query = searchKey.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
  }
  @Published private(set) var query = "" {
    didSet {
      fetchSuggestions()
    }
  }

  init(
    categoryRepository: CategoryRepository = CategoryRepositoryImpl(),
    suggestionRepository: SuggestionRepository = SuggestionRepositoryImpl()
  ) {
    self.categoryRepository = categoryRepository
    self.suggestionRepository = suggestionRepository
  }

  func fetchCategories() {
    Task {
      do {
        try await categoryRepository.fetchAll()
      } catch {
        print("Failed to fetch categories: \(error)")
      }
    }
  }

  private func fetchSuggestions() {
    Task {
      do {
        try await suggestionRepository.fetchSuggestions(query: query)
      } catch {
        print("Failed to fetch suggestions: \(error)")
      }
    }
  }
}
