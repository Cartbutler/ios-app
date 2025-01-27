//
//  CartButlerApp.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-20.
//

import SwiftData
import SwiftUI

@main
struct CartButlerApp: App {
  var body: some Scene {
    WindowGroup {
      MainView()
    }
    .modelContainer(MainContainer.shared)
  }
}
