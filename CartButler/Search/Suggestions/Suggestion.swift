//
//  Suggestion.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-24.
//

import SwiftData

@Model
final class Suggestion {
  @Attribute(.unique)
  var id: Int
  var name: String
  var priority: Int
  var suggestionSet: SuggestionSet

  init(id: Int, name: String, priority: Int, suggestionSet: SuggestionSet) {
    self.id = id
    self.name = name
    self.priority = priority
    self.suggestionSet = suggestionSet
  }

  convenience init(dto: SuggestionDTO, suggestionSet: SuggestionSet) {
    self.init(
      id: dto.id,
      name: dto.name,
      priority: dto.priority,
      suggestionSet: suggestionSet)
  }
}

@Model
final class SuggestionSet {
  @Attribute(.unique)
  var query: String
  @Relationship(deleteRule: .cascade, inverse: \Suggestion.suggestionSet)
  var suggestions: [Suggestion]

  init(query: String, suggestions: [Suggestion]) {
    self.query = query
    self.suggestions = suggestions
  }

  convenience init(query: String, suggestionDTOs: [SuggestionDTO]) {
    self.init(query: query, suggestions: [])
    self.suggestions = suggestionDTOs.map { Suggestion(dto: $0, suggestionSet: self) }
  }
}
