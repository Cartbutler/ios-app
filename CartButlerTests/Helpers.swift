//
//  Helpers.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-10.
//
import Foundation
import Testing

func forContextSavedConfirmation(body: () async throws -> Void) async rethrows {
  try await confirmation { contextSaved in
    var observer: Any?
    observer = NotificationCenter.default.addObserver(
      forName: .NSManagedObjectContextDidSave,
      object: nil,
      queue: nil,
      using: { _ in
        observer.flatMap(NotificationCenter.default.removeObserver)
        contextSaved()
      }
    )
    // When
    try await body()
    try await Task.sleep(for: .seconds(0.1))
  }
}
