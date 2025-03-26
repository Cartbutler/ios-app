//
//  MainViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-11.
//

import Combine
import Foundation

@MainActor
final class MainViewModel: ObservableObject {
  @Published private(set) var cartCount = 0

  private var cancellables: Set<AnyCancellable> = []
  private let cartRepository: CartRepositoryProvider
  private var viewAppeared = false

  init(cartRepository: CartRepositoryProvider = CartRepository.shared) {
    self.cartRepository = cartRepository
  }

  func viewDidAppear() {
    guard !viewAppeared else { return }
    viewAppeared = true
    cartRepository.cartPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cart in
        self?.cartCount = cart?.cartItems.count ?? 0
      }
      .store(in: &cancellables)

    Task { @CartActor in
      try? await cartRepository.refreshCart()
    }
  }
}
