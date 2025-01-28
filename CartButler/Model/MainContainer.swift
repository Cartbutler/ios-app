//
//  MainContainer.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-24.
//

import SwiftData

protocol DataPreloader: PersistentModel {
  static var defaults: [Self] { get }
}

actor MainContainer {
  
  @MainActor
  static let shared: ModelContainer = createContainer()
  
  @MainActor
  private static func createContainer() -> ModelContainer {
    let schema = Schema([Category.self, Suggestion.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    let container =  try! ModelContainer(for: schema, configurations: [modelConfiguration])
    preLoadData(container: container)
    return container
  }
  
  @MainActor
  static private func preLoadData(container: ModelContainer) {
    preloadData(Category.self, container: container)
    preloadData(Suggestion.self, container: container)
  }
  
  @MainActor
  static private func preloadData<T: DataPreloader>(_ type: T.Type, container: ModelContainer) {
    let descriptor = FetchDescriptor<T>()
    let count = try! container.mainContext.fetchCount(descriptor)
    if count > 0 { return }
    T.defaults.forEach { container.mainContext.insert($0) }
  }
}
