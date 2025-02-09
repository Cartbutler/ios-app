//
//  SuggestionRepository.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-08.
//

import Foundation

struct SuggestionDTO: Decodable, Equatable {
  let id: Int
  let name: String
  let priority: Int
}
