//
//  ProductDetailsViewModel.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-21.
//
import Foundation

@MainActor
final class ProductDetailsViewModel: ObservableObject {
  @Published var product: ProductDTO?
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var alertMessage: String?
  @Published var showAlert = false

  private let apiService: APIServiceProvider
  private let cartRepository: CartRepositoryProvider
  private let productID: Int

  init(
    apiService: APIServiceProvider = APIService.shared,
    cartRepository: CartRepositoryProvider = CartRepository.shared,
    productID: Int
  ) {
    self.apiService = apiService
    self.cartRepository = cartRepository
    self.productID = productID
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

  func formattedPrice(from product: ProductDTO) -> String {
    if let minPrice = product.minPrice,
      let maxPrice = product.maxPrice,
      minPrice < maxPrice
    {
      "\(Formatter.currency(from: minPrice)) - \(Formatter.currency(from: maxPrice))"
    } else {
      Formatter.currency(from: product.price)
    }
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
