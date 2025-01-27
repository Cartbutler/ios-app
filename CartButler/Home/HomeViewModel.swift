//
//  HomeViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-25.
//
import Foundation
import SwiftUI
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
  
  private let container: ModelContainer
  
  init(container: ModelContainer = MainContainer.shared) {
    self.container = container
  }
  
  @Published var searchKey = "" {
    didSet {
      fetchItems()
    }
  }
  
  @Published private(set) var suggestions: [String] = []
  
  func fetchItems() {
    let filterKey = searchKey.trimmingCharacters(in: .whitespaces).lowercased()
    var descriptor = FetchDescriptor<Suggestion>(
      predicate: #Predicate { $0.searchKey == filterKey }
    )
    descriptor.fetchLimit = 1
    
    if let result = try? container.mainContext.fetch(descriptor).first {
      suggestions = result.suggestions
    } else {
      suggestions = []
    }
  }
}
