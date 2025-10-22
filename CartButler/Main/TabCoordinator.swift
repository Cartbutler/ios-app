//
//  TabCoordinator.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-10-20.
//
import SwiftUI

@MainActor
class TabCoordinator: ObservableObject {
  @Published var activeSheet: SheetDestination?
  @Published var selectedTab: Tab = .search
  
  @Published var accountPath = NavigationPath()
  @Published var cartPath = NavigationPath()
  @Published var searchPath = NavigationPath()
  @Published var sheetPath = NavigationPath()
  
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
  
  // MARK: - Sheet Management
  
  func presentSheet(_ sheet: SheetDestination) {
    activeSheet = sheet
  }
  
  func dismissSheet() {
    activeSheet = nil
    sheetPath = NavigationPath() // Clear path on dismiss
  }
  
  func navigateInSheet(to destination: some Hashable) {
    sheetPath.append(destination)
  }
  
  func navigateBackInSheet() {
    if !sheetPath.isEmpty {
      sheetPath.removeLast()
    }
  }
  
  func navigateToSheetRoot() {
    sheetPath.removeLast(sheetPath.count)
  }
  
  // Check if we can navigate back in the current context
  var canNavigateBack: Bool {
    if activeSheet != nil {
      return !sheetPath.isEmpty
    } else {
      switch selectedTab {
      case .search: return !searchPath.isEmpty
      case .cart: return !cartPath.isEmpty
      case .account: return !accountPath.isEmpty
      }
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

enum SheetDestination: Hashable, Identifiable {
  case shoppingResultsFilter(stores: [StoreFilterDTO], filterParameters: Binding<FilterParameters?>)
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.shoppingResultsFilter(let lhsStores, let lhsFilterParameters),
          .shoppingResultsFilter(let rhsStores, let rhsFilterParameters)):
      return lhsStores == rhsStores && lhsFilterParameters.wrappedValue == rhsFilterParameters.wrappedValue
    }
  }
  
  func hash(into hasher: inout Hasher) {
    switch self {
    case .shoppingResultsFilter(let stores , let filters):
      hasher.combine(stores)
      hasher.combine(filters.wrappedValue)
    }
  }
  
  var id: Self { self }
  
  @MainActor
  @ViewBuilder
  var view: some View {
    switch self {
    case .shoppingResultsFilter(let stores, let filterParameters):
      SheetWithNavigationView {
        ShoppingResultsFilterView(
          stores: stores,
          filterParameters: filterParameters
        )
      }
    }
  }
  
}

struct SheetWithNavigationView<Content: View>: View {
  @EnvironmentObject var coordinator: TabCoordinator
  @ViewBuilder let content: () -> Content
  
  var body: some View {
    NavigationStack(path: $coordinator.sheetPath) {
      content()
        .withAppNavigation()
    }
  }
}
