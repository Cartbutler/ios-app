//
//  MainView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-20.
//

import SwiftUI

struct MainView: View {

  @StateObject private var viewModel = MainViewModel()

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
        .badge(viewModel.cartCount)
      Text("Account")
        .tabItem {
          Label("Account", systemImage: "person")
        }
    }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .onAppear {
      viewModel.viewDidAppear()
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
