//
//  MainView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-20.
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject private var coordinator: TabCoordinator
  @StateObject private var viewModel = MainViewModel()

  var body: some View {
    TabView(selection: $coordinator.selectedTab) {
      SearchView()
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
        .tag(TabCoordinator.Tab.search)
      CartView()
        .tabItem {
          Label("Cart", systemImage: "cart")
        }
        .badge(viewModel.cartCount)
        .tag(TabCoordinator.Tab.cart)
      Text("Account")
        .tabItem {
          Label("Account", systemImage: "person")
        }
        .tag(TabCoordinator.Tab.account)
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
