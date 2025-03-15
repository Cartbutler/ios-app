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

extension ModelContainer {
  func newBackgroundContext() -> ModelContext {
    ModelContext(self)
  }
}

actor MainContainer {

  @MainActor
  static let shared: ModelContainer = createContainer()

  @MainActor
  private static func createContainer() -> ModelContainer {
    let models: [any PersistentModel.Type] = [Category.self, Suggestion.self]
    let schema = Schema(models)
    let modelConfiguration = ModelConfiguration(schema: schema)
    let container: ModelContainer
    do {
      container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      // Delete everything and recreate the container in case the DB schema changed
      models.forEach { model in
        let tempContainer = try? ModelContainer(for: model)
        tempContainer?.deleteAllData()
      }
      container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    return container
  }

  @MainActor
  static private func preLoadData(container: ModelContainer) {
  }

  @MainActor
  static private func preloadData<T: DataPreloader>(_ type: T.Type, container: ModelContainer) {
    let descriptor = FetchDescriptor<T>()
    let count = try! container.mainContext.fetchCount(descriptor)
    if count > 0 { return }
    T.defaults.forEach { container.mainContext.insert($0) }
  }
}
