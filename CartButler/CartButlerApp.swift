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
  
  init() {
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = UIColor.themeBackground
    UITabBar.appearance().standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
  }
  
  var body: some Scene {
    WindowGroup {
      MainView()
    }
    .modelContainer(MainContainer.shared)
  }
}
