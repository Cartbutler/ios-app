//
//  ShoppingResultsViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import Foundation

@MainActor
final class ShoppingResultsViewModel: ObservableObject {

  enum State: Equatable {
    case idle
    case empty
    case loading
    case loaded(ShoppingResultsDTO)
    case error(String)
  }

  private(set) var allResults = [ShoppingResultsDTO]()
  @Published private(set) var otherResults = [ShoppingResultsDTO]()
  @Published private(set) var state = State.idle {
    didSet {
      if case .error(let message) = state, !message.isEmpty { showAlert = true }
    }
  }
  @Published var showAlert = false
  @Published var filterParameters: FilterParameters? {
    didSet { refetchResults() }
  }
  var hasFilters: Bool { filterParameters != nil }
  var isFilterAvailable: Bool {
    allResults.count > 1 || filterParameters != nil
  }

  private let apiService: APIServiceProvider
  private let cartRepository: CartRepositoryProvider
  private(set) var availableStores = [StoreFilterDTO]()

  init(
    apiService: APIServiceProvider = APIService.shared,
    cartRepository: CartRepositoryProvider = CartRepository.shared
  ) {
    self.apiService = apiService
    self.cartRepository = cartRepository
  }

  func fetchResults() async {
    guard state == .idle else { return }
    state = .loading

    do {
      if let cartId = try await cartRepository.cartPublisher.values.first()??.id {
        allResults = try await apiService.fetchShoppingResults(
          cartId: cartId,
          storeIds: filterParameters?.storeIds,
          radius: filterParameters?.radius,
          lat: filterParameters?.latitude,
          long: filterParameters?.longitude
        )

        // Store original store information if this is the first fetch
        setOriginalStores(from: allResults)

        if let cheapest = allResults.first {
          state = .loaded(cheapest)
          otherResults = Array(allResults.dropFirst())
        } else {
          state = .empty
          otherResults = []
        }
      } else {
        state = .error("No items in cart")
      }
    } catch {
      state = .error("Failed to load shopping results: \(error.localizedDescription)")
    }
  }

  private func setOriginalStores(from results: [ShoppingResultsDTO]) {
    guard availableStores.isEmpty else { return }
    availableStores = results.map { result in
      StoreFilterDTO(
        id: result.storeId,
        name: result.storeName,
        imagePath: result.storeImage,
        isSelected: true
      )
    }
  }

  private func refetchResults() {
    Task {
      state = .idle
      allResults = []
      otherResults = []
      await fetchResults()
    }
  }
}
