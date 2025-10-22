//
//  TabCoordinator.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-10-20.
//
import SwiftUI

@MainActor
class TabCoordinator: ObservableObject {
  @Published var selectedTab: Tab = .search
  @Published var searchPath = NavigationPath()
  @Published var cartPath = NavigationPath()
  @Published var accountPath = NavigationPath()
  
  enum Tab: Hashable {
    case search
    case cart
    case account
  }
  
  // Navigate in current tab
  func navigate(to destination: some Hashable) {
    switch selectedTab {
    case .search:
      searchPath.append(destination)
    case .cart:
      cartPath.append(destination)
    case .account:
      accountPath.append(destination)
    }
  }
  
  // Navigate and switch tabs
  func switchTab(to tab: Tab, then destination: (any Hashable)? = nil) {
    selectedTab = tab
    if let destination {
      // Small delay to ensure tab switch completes
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.navigate(to: destination)
      }
    }
  }
  
  func navigateBack() {
    switch selectedTab {
    case .search:
      if !searchPath.isEmpty { searchPath.removeLast() }
    case .cart:
      if !cartPath.isEmpty { cartPath.removeLast() }
    case .account:
      if !accountPath.isEmpty { accountPath.removeLast() }
    }
  }
  
  func navigateToRoot() {
    switch selectedTab {
    case .search:
      searchPath.removeLast(searchPath.count)
    case .cart:
      cartPath.removeLast(cartPath.count)
    case .account:
      accountPath.removeLast(accountPath.count)
    }
  }
}

extension View {
  func withAppNavigation() -> some View {
    self
      // Navigation using DTOs directly
      .navigationDestination(for: BasicProductDTO.self) { product in
        ProductDetailsView(product: product)
      }
      .navigationDestination(for: Category.self) { category in
        ProductsResultsView(searchType: .category(category))
      }
      .navigationDestination(for: SearchType.self) { searchType in
        ProductsResultsView(searchType: searchType)
      }
      .navigationDestination(for: ShoppingResultsDTO.self) { result in
        StoreDetailsView(result: result)
      }
      // Use enums only for navigation without data
      .navigationDestination(for: AppDestination.self) { destination in
        destination.view
      }
  }
}

enum AppDestination: Hashable {
  case shoppingResults
  
  @MainActor
  @ViewBuilder
  var view: some View {
    switch self {
    case .shoppingResults:
      ShoppingResultsView()
    }
  }
}
