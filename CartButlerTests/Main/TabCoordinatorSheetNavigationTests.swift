//
//  TabCoordinatorSheetNavigationTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-10-21.
//
import Combine
import Foundation
import Mockable
import SwiftUI
import Testing

@testable import CartButler

@Suite("TabCoordinator Sheet Navigation Tests")
@MainActor
struct TabCoordinatorSheetNavigationTests {
  
  // MARK: - Initial Sheet Path State
  
  @Test("Initial state should have empty sheet path")
  func initialSheetPath() {
    let coordinator = TabCoordinator()
    #expect(coordinator.sheetPath.isEmpty)
  }
  
  // MARK: - Sheet Path Navigation Tests
  
  @Test("Navigate in sheet should append to sheet path")
  func navigateInSheet() {
    let coordinator = TabCoordinator()
    let product = MockData.product()
    
    coordinator.navigateInSheet(to: product)
    
    #expect(coordinator.sheetPath.count == 1)
  }
  
  @Test("Multiple navigations in sheet should build path")
  func multipleNavigationsInSheet() {
    let coordinator = TabCoordinator()
    
    coordinator.navigateInSheet(to: MockData.product(id: 1))
    coordinator.navigateInSheet(to: MockData.product(id: 2))
    coordinator.navigateInSheet(to: MockData.category())
    
    #expect(coordinator.sheetPath.count == 3)
  }
  
  @Test("Navigate back in sheet should remove last item")
  func navigateBackInSheet() {
    let coordinator = TabCoordinator()
    
    coordinator.navigateInSheet(to: MockData.product(id: 1))
    coordinator.navigateInSheet(to: MockData.product(id: 2))
    #expect(coordinator.sheetPath.count == 2)
    
    coordinator.navigateBackInSheet()
    
    #expect(coordinator.sheetPath.count == 1)
  }
  
  @Test("Navigate back in empty sheet path should do nothing")
  func navigateBackInEmptySheetPath() {
    let coordinator = TabCoordinator()
    #expect(coordinator.sheetPath.isEmpty)
    
    coordinator.navigateBackInSheet()
    
    #expect(coordinator.sheetPath.isEmpty)
  }
  
  @Test("Navigate to sheet root should clear all items")
  func navigateToSheetRoot() {
    let coordinator = TabCoordinator()
    
    coordinator.navigateInSheet(to: MockData.product(id: 1))
    coordinator.navigateInSheet(to: MockData.product(id: 2))
    coordinator.navigateInSheet(to: MockData.category())
    #expect(coordinator.sheetPath.count == 3)
    
    coordinator.navigateToSheetRoot()
    
    #expect(coordinator.sheetPath.isEmpty)
  }
  
  @Test("Navigate to sheet root on empty path should do nothing")
  func navigateToSheetRootWhenEmpty() {
    let coordinator = TabCoordinator()
    #expect(coordinator.sheetPath.isEmpty)
    
    coordinator.navigateToSheetRoot()
    
    #expect(coordinator.sheetPath.isEmpty)
  }
  
  // MARK: - Present/Dismiss Sheet Path Tests
  
  @Test("Dismiss sheet should clear sheet path")
  func dismissSheetClearsPath() {
    let coordinator = TabCoordinator()
    
    // Present sheet
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    // Navigate within sheet
    coordinator.navigateInSheet(to: MockData.product(id: 1))
    coordinator.navigateInSheet(to: MockData.product(id: 2))
    #expect(coordinator.sheetPath.count == 2)
    
    // Dismiss sheet
    coordinator.dismissSheet()
    
    // Path should be cleared
    #expect(coordinator.sheetPath.isEmpty)
    #expect(coordinator.activeSheet == nil)
  }
  
  // MARK: - Sheet and Tab Navigation Independence
  
  @Test("Sheet path should be independent of tab paths")
  func sheetPathIndependence() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Navigate in search tab
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.product(id: 2))
    #expect(coordinator.searchPath.count == 2)
    
    // Present sheet and navigate within it
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    coordinator.navigateInSheet(to: MockData.category())
    
    // Both paths should be independent
    #expect(coordinator.searchPath.count == 2)
    #expect(coordinator.sheetPath.count == 1)
    
    // Navigate back in sheet
    coordinator.navigateBackInSheet()
    #expect(coordinator.sheetPath.isEmpty)
    #expect(coordinator.searchPath.count == 2) // Unchanged
    
    // Dismiss sheet
    coordinator.dismissSheet()
    #expect(coordinator.searchPath.count == 2) // Still unchanged
  }
  
  @Test("Tab navigation should not affect sheet path")
  func tabNavigationDoesNotAffectSheetPath() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Present sheet and navigate within it
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    coordinator.navigateInSheet(to: MockData.product())
    #expect(coordinator.sheetPath.count == 1)
    
    // Navigate in search tab
    coordinator.navigate(to: MockData.category())
    #expect(coordinator.searchPath.count == 1)
    
    // Sheet path should be unchanged
    #expect(coordinator.sheetPath.count == 1)
    
    // Navigate back in tab
    coordinator.navigateBack()
    #expect(coordinator.searchPath.isEmpty)
    
    // Sheet path should still be unchanged
    #expect(coordinator.sheetPath.count == 1)
  }
  
  @Test("Switch tab should not affect sheet path")
  func switchTabDoesNotAffectSheetPath() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Present sheet and navigate
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    coordinator.navigateInSheet(to: MockData.product(id: 1))
    coordinator.navigateInSheet(to: MockData.product(id: 2))
    #expect(coordinator.sheetPath.count == 2)
    
    // Switch tab
    coordinator.switchTab(to: .cart)
    
    // Sheet path should remain
    #expect(coordinator.sheetPath.count == 2)
    #expect(coordinator.activeSheet != nil)
  }
  
  // MARK: - Can Navigate Back Tests
  
  @Test("Can navigate back should be false initially")
  func canNavigateBackInitially() {
    let coordinator = TabCoordinator()
    #expect(coordinator.canNavigateBack == false)
  }
  
  @Test("Can navigate back should be true with tab navigation")
  func canNavigateBackWithTabNavigation() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    coordinator.navigate(to: MockData.product())
    
    #expect(coordinator.canNavigateBack == true)
  }
  
  @Test("Can navigate back should be true with sheet navigation")
  func canNavigateBackWithSheetNavigation() {
    let coordinator = TabCoordinator()
    
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    #expect(coordinator.canNavigateBack == false)
    
    coordinator.navigateInSheet(to: MockData.product())
    
    #expect(coordinator.canNavigateBack == true)
  }
  
  @Test("Can navigate back should prioritize sheet navigation")
  func canNavigateBackPrioritizesSheet() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Navigate in tab
    coordinator.navigate(to: MockData.product())
    #expect(coordinator.canNavigateBack == true)
    
    // Present sheet (no navigation within it)
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    
    // Should check sheet path (empty) not tab path
    #expect(coordinator.canNavigateBack == false)
    
    // Navigate in sheet
    coordinator.navigateInSheet(to: MockData.category())
    
    // Now should be true based on sheet path
    #expect(coordinator.canNavigateBack == true)
  }
  
  @Test("Can navigate back after dismissing sheet")
  func canNavigateBackAfterDismissingSheet() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // Navigate in tab
    coordinator.navigate(to: MockData.product())
    
    // Present sheet with navigation
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    coordinator.navigateInSheet(to: MockData.category())
    #expect(coordinator.canNavigateBack == true)
    
    // Dismiss sheet
    coordinator.dismissSheet()
    
    // Should now reflect tab navigation state
    #expect(coordinator.canNavigateBack == true)
  }
  
  // MARK: - Complex Scenarios
  
  @Test("Complex sheet navigation scenario")
  func complexSheetNavigationScenario() {
    let coordinator = TabCoordinator()
    coordinator.selectedTab = .search
    
    // 1. Navigate in search tab
    coordinator.navigate(to: MockData.product(id: 1))
    coordinator.navigate(to: MockData.category())
    #expect(coordinator.searchPath.count == 2)
    
    // 2. Present sheet
    let stores = MockData.stores()
    let filterParams: Binding<FilterParameters?> = .constant(MockData.filterParameters())
    coordinator.presentSheet(
      .shoppingResultsFilter(stores: stores, filterParameters: filterParams)
    )
    #expect(coordinator.sheetPath.isEmpty)
    
    // 3. Navigate within sheet
    coordinator.navigateInSheet(to: MockData.product(id: 2))
    coordinator.navigateInSheet(to: MockData.product(id: 3))
    #expect(coordinator.sheetPath.count == 2)
    
    // 4. Navigate back in sheet
    coordinator.navigateBackInSheet()
    #expect(coordinator.sheetPath.count == 1)
    
    // 5. Navigate to sheet root
    coordinator.navigateToSheetRoot()
    #expect(coordinator.sheetPath.isEmpty)
    
    // 6. Navigate again in sheet
    coordinator.navigateInSheet(to: MockData.category())
    #expect(coordinator.sheetPath.count == 1)
    
    // 7. Dismiss sheet
    coordinator.dismissSheet()
    #expect(coordinator.activeSheet == nil)
    #expect(coordinator.sheetPath.isEmpty)
    
    // 8. Tab navigation should be preserved
    #expect(coordinator.searchPath.count == 2)
    
    // 9. Can still navigate in tab
    coordinator.navigateBack()
    #expect(coordinator.searchPath.count == 1)
  }
}
