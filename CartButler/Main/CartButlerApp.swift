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
  @StateObject private var coordinator = TabCoordinator()
  
  var body: some Scene {
    WindowGroup {
      if !isRunningTests {
        MainView()
      } else {
        EmptyView()
      }
    }
    .modelContainer(MainContainer.shared)
    .environmentObject(coordinator)
  }

  private var isRunningTests: Bool {
    #if DEBUG
      ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    #else
      false
    #endif
  }
}
