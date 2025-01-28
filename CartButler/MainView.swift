//
//  MainView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-20.
//

import SwiftUI

struct MainView: View {

  var body: some View {
    TabView {
      HomeView()
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
      Text("Cart")
        .tabItem {
          Label("Cart", systemImage: "cart")
        }
    }
  }
}

#Preview("English") {
  MainView()
}


#Preview("pt-BR") {
  MainView()
    .environment(\.locale, .init(identifier: "pt-BR"))
}
