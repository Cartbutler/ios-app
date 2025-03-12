//
//  Extensions.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-09.
//

import Combine
import Foundation

extension AsyncSequence {
  func first() async throws -> Element? {
    try await first(where: { _ in true })
  }
}
