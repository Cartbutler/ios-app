//
//  LanguageService.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-05.
//

import Foundation
import Mockable

@Mockable
protocol LanguageServiceProvider: Sendable {
  var languageID: String { get }
}

final class LanguageService: LanguageServiceProvider {
  static let shared = LanguageService()

  var languageID: String {
    Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
  }

  private init() {}
}
