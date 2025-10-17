//
//  ProductDetailsViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-21.
//

import Combine
import Foundation

@MainActor
final class ProductDetailsViewModel: ObservableObject {
  @Published var product: ProductDTO?
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var alertMessage: String?
  @Published var showAlert = false
  @Published var quantityInCart = 0

  private let apiService: APIServiceProvider
  private let cartRepository: CartRepositoryProvider
  private let productID: Int
  private var cartSubscription: AnyCancellable?

  init(
    apiService: APIServiceProvider = APIService.shared,
    cartRepository: CartRepositoryProvider = CartRepository.shared,
    productID: Int
  ) {
    self.apiService = apiService
    self.cartRepository = cartRepository
    self.productID = productID
    
    // Subscribe to cart changes
    setupCartSubscription()
  }
  
  private func setupCartSubscription() {
    cartSubscription = cartRepository.cartPublisher
      .sink { @MainActor [weak self] cart in
        guard let self else { return }
        quantityInCart = cart?.quantity(for: productID) ?? 0
      }
  }

  func fetchProduct() async {
    guard !isLoading, product == nil else { return }
    isLoading = true
    errorMessage = nil

    do {
      product = try await apiService.fetchProduct(id: productID)
    } catch {
      errorMessage = "Failed to load product details: \(error.localizedDescription)"
    }

    isLoading = false
  }

  func addToCart() async {
    do {
      try await cartRepository.increment(productId: productID)
    } catch {
      alertMessage = "Failed to add product to cart, please try again."
      showAlert = true
    }
  }
}
