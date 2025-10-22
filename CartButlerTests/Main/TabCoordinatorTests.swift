//
//  TabCoordinatorTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-10-20.
//
import Combine
import Foundation
import Mockable
import SwiftUI
import Testing

@testable import CartButler

struct MockData {
  static func product(
    id: Int = 1,
    name: String = "Test Product",
    minPrice: Double? = 9.99,
    maxPrice: Double? = 19.99,
    imagePath: String = "test-image.jpg"
  ) -> BasicProductDTO {
    BasicProductDTO(
      productId: id,
      productName: name,
      minPrice: minPrice,
      maxPrice: maxPrice,
      imagePath: imagePath
    )
  }
  
  static func category(
    id: Int = 1,
    name: String = "Test Category"
  ) -> CartButler.Category {
    Category(id: id, name: name, imagePath: "")
  }
  
  static func stores(count: Int = 1) -> [StoreFilterDTO] {
    (1...count).map {
      StoreFilterDTO(id: $0, name: "Store \($0)", imagePath: "", isSelected: false)
    }
  }
  
  static func filterParameters() -> FilterParameters {
    FilterParameters(distance: 0, selectedStoreIds: [], showCompleteOnly: false)
  }
}

// MARK: - TabCoordinator Tests

@Suite("TabCoordinator Tests")
@MainActor
struct TabCoordinatorTests {
  
  // MARK: - Initial State Tests
  
  @Test("Initial state should have search tab selected")
  func initialTabSelection() {
    let coordinator = TabCoordinator()
    #expect(coordinator.selectedTab == .search)
  }
  
  @Test("Initial state should have empty navigation paths")
  func initialNavigationPaths() {
    let coordinator = TabCoordinator()
    #expect(coordinator.searchPath.isEmpty)
    #expect(coordinator.cartPath.isEmpty)
    #expect(coordinator.accountPath.isEmpty)
  }
  
  // MARK: - Navigation Tests
  
  @Test("Navigate on search tab should append to search path")
  func navigateOnSearchTab() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    let product = MockData.product()
    
    coordinator.navigate(to: product)
    
    #expect(coordinator.searchPath.count == 1)
    #expect(coordinator.cartPath.isEmpty)
    #expect(coordinator.accountPath.isEmpty)
  }
  
  @Test("Navigate on cart tab should append to cart path")
  func navigateOnCartTab() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .cart
    let product = MockData.product()
    
    coordinator.navigate(to: product)
    
    #expect(coordinator.searchPath.isEmpty)
    #expect(coordinator.cartPath.count == 1)
    #expect(coordinator.accountPath.isEmpty)
  }
  
  @Test("Navigate multiple destinations should maintain navigation stack order")
  func navigateMultipleDestinations() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    let product1 = MockData.product(id: 1)
    let product2 = MockData.product(id: 2)
    let product3 = MockData.product(id: 3)
    
    coordinator.navigate(to: product1)
    coordinator.navigate(to: product2)
    coordinator.navigate(to: product3)
    
    #expect(coordinator.searchPath.count == 3)
  }
  
  @Test("Navigate with category should add to current tab path")
  func navigateWithCategory() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    let category = MockData.category()
    
    coordinator.navigate(to: category)
    
    #expect(coordinator.searchPath.count == 1)
  }
  
  // MARK: - Back Navigation Tests
  
  @Test("Navigate back with items in stack should remove last item")
  func navigateBackWithItems() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    
    coordinator.navigateBack()
    
    #expect(coordinator.searchPath.count == 1)
  }
  
  @Test("Navigate back with empty stack should do nothing")
  func navigateBackWithEmptyStack() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    coordinator.navigateBack()
    
    #expect(coordinator.searchPath.isEmpty)
  }
  
  @Test("Navigate back on different tab should only affect current tab")
  func navigateBackOnDifferentTab() {
    let coordinator = TabCoordinator()
    
    // Setup search tab with navigation
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    
    // Setup cart tab with navigation
    coordinator.selectedTab = .cart
    coordinator.navigate(to: MockData.product(id: 3))
    
    // Navigate back on cart tab
    coordinator.navigateBack()
    
    #expect(coordinator.searchPath.count == 2) // Unchanged
    #expect(coordinator.cartPath.isEmpty)
  }
  
  // MARK: - Root Navigation Tests
  
  @Test("Navigate to root should clear all items from current tab")
  func navigateToRootClearsCurrentTab() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    coordinator.navigate(to: MockData.product(id: 3))
    
    coordinator.navigateToRoot()
    
    #expect(coordinator.searchPath.isEmpty)
  }
  
  @Test("Navigate to root should not affect other tabs")
  func navigateToRootPreservesOtherTabs() {
    let coordinator = TabCoordinator()
    
    // Add items to search tab
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.product(id: 1))
    
    // Add items to cart tab and clear it
    coordinator.selectedTab = .cart
    coordinator.navigate(to: MockData.product(id: 2))
    coordinator.navigateToRoot()
    
    #expect(coordinator.searchPath.count == 1) // Unchanged
    #expect(coordinator.cartPath.isEmpty)
  }
  
  @Test("Navigate to root with empty stack should do nothing")
  func navigateToRootWithEmptyStack() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    coordinator.navigateToRoot()
    
    #expect(coordinator.searchPath.isEmpty)
  }
  
  // MARK: - Tab Switching Tests
  
  @Test("Switch tab should change selected tab")
  func switchTabChangesSelection() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    coordinator.switchTab(to: .cart)
    
    #expect(coordinator.selectedTab == .cart)
  }
  
  @Test("Switch tab should preserve navigation stacks")
  func switchTabPreservesStacks() {
    let coordinator = TabCoordinator()
    
    // Setup search tab with navigation
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    
    // Switch to cart
    coordinator.switchTab(to: .cart)
    
    #expect(coordinator.searchPath.count == 2)
    #expect(coordinator.cartPath.isEmpty)
  }
  
  @Test("Switch tab with destination should navigate after switching")
  func switchTabWithDestination() async throws {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    let product = MockData.product()
    
    coordinator.switchTab(to: .cart, then: product)
    
    // Wait for async dispatch
    try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
    
    #expect(coordinator.selectedTab == .cart)
    #expect(coordinator.cartPath.count == 1)
  }
  
  // MARK: - Complex Navigation Flow Tests
  
  @Test("Complex navigation flow should maintain correct state")
  func complexNavigationFlow() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Simulate user journey
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    coordinator.navigateBack()
    coordinator.switchTab(to: .cart)
    coordinator.navigate(to: AppDestination.shoppingResults)
    coordinator.navigateToRoot()
    coordinator.switchTab(to: .search)
    
    #expect(coordinator.selectedTab == .search)
    #expect(coordinator.searchPath.count == 1)
    #expect(coordinator.cartPath.isEmpty)
  }
  
  @Test("Navigation across multiple tabs should maintain independent stacks")
  func navigationAcrossMultipleTabs() {
    let coordinator = TabCoordinator()
    
    // Navigate in search tab
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    
    // Navigate in cart tab
    coordinator.selectedTab = .cart
    coordinator.navigate(to: MockData.product(id: 3))
    
    // Navigate in account tab
    coordinator.selectedTab = .account
    
    #expect(coordinator.searchPath.count == 2)
    #expect(coordinator.cartPath.count == 1)
    #expect(coordinator.accountPath.count == 0)
  }
  
  @Test("Deep navigation and back should work correctly")
  func deepNavigationAndBack() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Create deep navigation
    for i in 1...5 {
      coordinator.navigate(to: MockData.product(id: i))
    }
    
    #expect(coordinator.searchPath.count == 5)
    
    // Navigate back twice
    coordinator.navigateBack()
    coordinator.navigateBack()
    
    #expect(coordinator.searchPath.count == 3)
  }
  
  // MARK: - Edge Case Tests
  
  @Test("Navigate back multiple times on empty stack should not crash")
  func navigateBackMultipleTimesOnEmptyStack() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    for _ in 0..<10 {
      coordinator.navigateBack()
    }
    
    #expect(coordinator.searchPath.isEmpty)
  }
  
  @Test("Navigate to root multiple times should be idempotent")
  func navigateToRootIdempotent() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.product())
    
    coordinator.navigateToRoot()
    coordinator.navigateToRoot()
    coordinator.navigateToRoot()
    
    #expect(coordinator.searchPath.isEmpty)
  }
  
  @Test("Rapid tab switching should maintain correct state")
  func rapidTabSwitching() {
    let coordinator = TabCoordinator()
    
    // Add navigation to each tab
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.product(id: 1))
    
    coordinator.selectedTab = .cart
    coordinator.navigate(to: MockData.product(id: 2))
    
    coordinator.selectedTab = .account
    
    // Rapid switching
    for _ in 0..<10 {
      coordinator.switchTab(to: .search)
      coordinator.switchTab(to: .cart)
      coordinator.switchTab(to: .account)
    }
    
    #expect(coordinator.searchPath.count == 1)
    #expect(coordinator.cartPath.count == 1)
    #expect(coordinator.accountPath.count == 0)
  }
  
  @Test("Mixed navigation operations should work correctly")
  func mixedNavigationOperations() {
    let coordinator = TabCoordinator()
    
    // Search tab operations
    coordinator.selectedTab = .search
    coordinator.navigate(to: MockData.category(id: 1))
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    coordinator.navigateBack()
    
    // Cart tab operations
    coordinator.selectedTab = .cart
    coordinator.navigate(to: AppDestination.shoppingResults)
    
    // Account tab operations
    coordinator.selectedTab = .account
    coordinator.navigateToRoot()
    
    #expect(coordinator.searchPath.count == 2)
    #expect(coordinator.cartPath.count == 1)
    #expect(coordinator.accountPath.isEmpty)
  }
  
  // MARK: - Performance Tests
  
  @Test("Large navigation stack should handle operations efficiently")
  func largeNavigationStack() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Add many items
    for i in 0..<100 {
      coordinator.navigate(to: MockData.product(id: i))
    }
    
    #expect(coordinator.searchPath.count == 100)
    
    // Clear all at once
    coordinator.navigateToRoot()
    
    #expect(coordinator.searchPath.isEmpty)
  }
  
  @Test("Switching tabs with large stacks should work")
  func switchingTabsWithLargeStacks() {
    let coordinator = TabCoordinator()
    
    // Build large stack in search
    coordinator.selectedTab = .search
    for i in 0..<50 {
      coordinator.navigate(to: MockData.product(id: i))
    }
    
    // Build large stack in cart
    coordinator.selectedTab = .cart
    for i in 50..<100 {
      coordinator.navigate(to: MockData.product(id: i))
    }
    
    // Switch tabs multiple times
    coordinator.switchTab(to: .search)
    coordinator.switchTab(to: .cart)
    coordinator.switchTab(to: .account)
    
    #expect(coordinator.searchPath.count == 50)
    #expect(coordinator.cartPath.count == 50)
    #expect(coordinator.accountPath.isEmpty)
  }
  
  // MARK: - Initial Sheet State Tests
  
  @Test("Initial state should have no active sheet")
  func initialSheetState() {
    let coordinator = TabCoordinator()
    #expect(coordinator.activeSheet == nil)
  }
  
  // MARK: - Sheet Presentation Tests
  
  @Test("Present sheet should set active sheet")
  func presentSheet() {
    let coordinator = TabCoordinator()
    let stores = MockData.stores(count: 2)
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    #expect(coordinator.activeSheet != nil)
    
    if case .shoppingResultsFilter(let presentedStores, _) = coordinator.activeSheet {
      #expect(presentedStores.count == 2)
      #expect(presentedStores.first?.name == "Store 1")
    } else {
      Issue.record("Wrong sheet type presented")
    }
  }
  
  @Test("Dismiss sheet should clear active sheet")
  func dismissSheet() {
    let coordinator = TabCoordinator()
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    #expect(coordinator.activeSheet != nil)
    
    coordinator.dismissSheet()
    
    #expect(coordinator.activeSheet == nil)
  }
  
  @Test("Replace sheet should update active sheet")
  func replaceSheet() {
    let coordinator = TabCoordinator()
    let initialStores = MockData.stores(count: 1)
    let updatedStores = MockData.stores(count: 3)
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: initialStores, filterParameters: filterParams)
    )
    
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: updatedStores, filterParameters: filterParams)
    )
    
    #expect(coordinator.activeSheet != nil)
    
    if case .shoppingResultsFilter(let presentedStores, _) = coordinator.activeSheet {
      #expect(presentedStores.count == 3)
    } else {
      Issue.record("Sheet not replaced correctly")
    }
  }
  
  // MARK: - Sheet Identity Tests
  
  @Test("Sheet destinations should have consistent identifiers")
  func sheetIdentifiers() {
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    
    let sheet1 = SheetDestination.shoppingResultsFilter(
      stores: stores,
      filterParameters: filterParams
    )
    let sheet2 = SheetDestination.shoppingResultsFilter(
      stores: stores,
      filterParameters: filterParams
    )
    
    #expect(sheet1.id == sheet2.id)
    #expect(sheet1.id == sheet1)
  }
  
  // MARK: - Integration Tests
  
  @Test("Navigation and sheet should work independently")
  func navigationAndSheetIndependence() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Navigate
    let product = MockData.product()
    coordinator.navigate(to: product)
    
    // Present sheet
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    // Verify both states
    #expect(coordinator.searchPath.count == 1)
    #expect(coordinator.activeSheet != nil)
    
    // Dismiss sheet shouldn't affect navigation
    coordinator.dismissSheet()
    #expect(coordinator.activeSheet == nil)
    #expect(coordinator.searchPath.count == 1)
  }
  
  @Test("Navigate back should not affect sheet")
  func navigateBackWithActiveSheet() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Setup navigation
    let product = MockData.product()
    coordinator.navigate(to: product)
    #expect(coordinator.searchPath.count == 1)
    
    // Present sheet
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    // Navigate back
    coordinator.navigateBack()
    
    // Sheet should remain, navigation should be cleared
    #expect(coordinator.activeSheet != nil)
    #expect(coordinator.searchPath.isEmpty)
  }
  
  @Test("Navigate to root should not affect sheet")
  func navigateToRootWithActiveSheet() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Setup multiple navigation levels
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    coordinator.navigate(to: MockData.category())
    #expect(coordinator.searchPath.count == 3)
    
    // Present sheet
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    // Navigate to root
    coordinator.navigateToRoot()
    
    // Sheet should remain, navigation should be cleared
    #expect(coordinator.activeSheet != nil)
    #expect(coordinator.searchPath.isEmpty)
  }
  
  @Test("Switch tab should not affect sheet")
  func switchTabWithActiveSheet() {
    let coordinator = TabCoordinator()
    
    // Start on search tab and present sheet
    coordinator.selectedTab = .search
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    // Switch to cart tab
    coordinator.switchTab(to: .cart)
    
    // Sheet should remain active
    #expect(coordinator.activeSheet != nil)
    #expect(coordinator.selectedTab == .cart)
  }
  
  // MARK: - Published Property Tests
  
  @Test("Active sheet changes should be published")
  func activeSheetPublishing() {
    let coordinator = TabCoordinator()
    
    // Verify initial state
    #expect(coordinator.activeSheet == nil)
    
    // Present sheet
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    // Verify sheet is presented
    #expect(coordinator.activeSheet != nil)
    
    // Dismiss sheet
    coordinator.dismissSheet()
    
    // Verify sheet is dismissed
    #expect(coordinator.activeSheet == nil)
  }

  // MARK: - Extended TabCoordinator Tests for Sheets
  
  @Test("Complex navigation scenario with sheets")
  func complexNavigationWithSheets() async {
    let coordinator = TabCoordinator()
    
    // 1. Start on search tab
    coordinator.selectedTab = .search
    #expect(coordinator.selectedTab == .search)
    
    // 2. Navigate to a product
    let product = MockData.product()
    coordinator.navigate(to: product)
    #expect(coordinator.searchPath.count == 1)
    
    // 3. Present a sheet
    let stores = MockData.stores(count: 2)
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    #expect(coordinator.activeSheet != nil)
    
    // 4. Switch to cart tab with navigation
    let cartProduct = MockData.product(id: 2, name: "Cart Product")
    coordinator.switchTab(to: .cart, then: cartProduct)
    
    // Allow for async navigation
    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
    
    #expect(coordinator.selectedTab == .cart)
    #expect(coordinator.cartPath.count == 1)
    #expect(coordinator.searchPath.count == 1) // Search path unchanged
    #expect(coordinator.activeSheet != nil) // Sheet still active
    
    // 5. Dismiss sheet
    coordinator.dismissSheet()
    #expect(coordinator.activeSheet == nil)
    
    // 6. Navigate back in cart
    coordinator.navigateBack()
    #expect(coordinator.cartPath.isEmpty)
    #expect(coordinator.searchPath.count == 1) // Search path still unchanged
  }
}
