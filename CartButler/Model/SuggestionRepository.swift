//
//  SuggestionRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-08.
//

import Foundation
import Mockable
import SwiftData
import SwiftUI

struct SuggestionDTO: Decodable, Equatable {
  let id: Int
  let name: String
  let priority: Int
}

@Mockable
protocol SuggestionRepository: Sendable {
  func fetchSuggestions(query: String) async throws
}

@MainActor
final class SuggestionRepositoryImpl: SuggestionRepository {
  private let apiService: APIServiceProvider
  private let container: ModelContainer

  init(
    apiService: APIServiceProvider = APIService(),
    container: ModelContainer = MainContainer.shared
  ) {
    self.apiService = apiService
    self.container = container
  }

  func fetchSuggestions(query: String) async throws {
    let suggestions = try await apiService.fetchSuggestions(query: query)
    Task {
      let context = container.newBackgroundContext()
      try context.transaction {
        context.insert(SuggestionSet(query: query, suggestionDTOs: suggestions))
      }
    }
  }
}
