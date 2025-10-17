//
//  ProductDetailViewModelTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-21.
//

import Combine
import Foundation
import Mockable
import Testing

@testable import CartButler

@MainActor
struct ProductDetailsViewModelTests {

  private let productDTO = ProductDTO(
    productId: 1,
    productName: "product",
    description: "description",
    price: 4.99,
    stock: 10,
    categoryId: 1,
    imagePath: "",
    createdAt: Date(),
    categoryName: "category",
    stores: [],
    minPrice: 3.99,
    maxPrice: 5.99
  )

  private let mockService = MockAPIServiceProvider()
  private let mockCartRepository = MockCartRepositoryProvider()
  private let cartPublisher = CurrentValueSubject<CartDTO?, Never>(nil)
  private let sut: ProductDetailsViewModel

  init() {
    given(mockCartRepository)
      .cartPublisher
      .willReturn(cartPublisher.eraseToAnyPublisher())
    
//    given(mockCartRepository)
//      .refreshCart()
//      .willReturn()
    
    sut = ProductDetailsViewModel(
      apiService: mockService,
      cartRepository: mockCartRepository,
      productID: productDTO.id
    )
  }

  // MARK: - Loading state

  @Test
  func fetchProductShouldSetLoadingState() async throws {
    // Given
    given(mockService)
      .fetchProduct(id: .any)
      .willReturn(productDTO)
    #expect(sut.isLoading == false)

    await confirmation { loadStarted in
      let subscription = sut.$isLoading.sink { isLoading in
        // Then
        if isLoading {
          loadStarted.confirm()
        }
      }
      // When
      await sut.fetchProduct()
      subscription.cancel()
    }

    // Then
    #expect(sut.isLoading == false)
  }

  // MARK: - Fetching product

  @Test
  func fetchProductSuccess() async throws {
    // Given
    given(mockService)
      .fetchProduct(id: .value(productDTO.productId))
      .willReturn(productDTO)

    #expect(sut.errorMessage == nil)
    #expect(sut.product == nil)

    // When
    await sut.fetchProduct()

    // Then
    #expect(sut.isLoading == false)
    #expect(sut.errorMessage == nil)
    #expect(sut.product == productDTO)
  }

  @Test
  func fetchProductFailure() async throws {
    // Given
    given(mockService)
      .fetchProduct(id: .any)
      .willThrow(NetworkError.invalidResponse)
    #expect(sut.errorMessage == nil)
    #expect(sut.product == nil)

    // When
    await sut.fetchProduct()

    // Then
    #expect(sut.isLoading == false)
    #expect(sut.errorMessage != nil)
    #expect(sut.product == nil)
  }

  // MARK: - Add to cart

  @Test
  func addToCartSuccess() async throws {
    // Given
    given(mockCartRepository)
      .increment(productId: .value(1))
      .willReturn()
    #expect(sut.alertMessage == nil)

    // When
    await sut.addToCart()

    // Then
    verify(mockCartRepository)
      .increment(productId: .value(1))
      .called(1)
    #expect(sut.alertMessage == nil)
    #expect(sut.showAlert == false)
  }

  @Test
  func addToCartFailure() async throws {
    // Given
    given(mockCartRepository)
      .increment(productId: .any)
      .willThrow(NetworkError.invalidResponse)
    #expect(sut.alertMessage == nil)

    // When
    await sut.addToCart()

    // Then
    verify(mockCartRepository)
      .increment(productId: .value(1))
      .called(1)
    #expect(sut.alertMessage != nil)
    #expect(sut.showAlert == true)
  }
  
  // MARK: - Cart Quantity Integration

  @Test
  func initializesWithZeroQuantityInCart() async throws {
    // Given/When - initialized in init()
    
    // Then
    #expect(sut.quantityInCart == 0)
  }

  @Test
  func updatesQuantityWhenCartChanges() async throws {
    // Given
    let cartWithProduct = CartDTO(
      id: 1,
      cartItems: [
        CartItemDTO(
          id: 1,
          cartId: 1,
          productId: 1,
          quantity: 3,
          product: productDTO
        )
      ]
    )
    
    #expect(sut.quantityInCart == 0)
    
    // When - publish cart with product
    cartPublisher.send(cartWithProduct)
    
    // Allow time for the publisher to update
//    try await Task.sleep(for: .milliseconds(100))
    
    // Then
    #expect(sut.quantityInCart == 3)
    
    // When - update cart with different quantity
    let updatedCart = CartDTO(
      id: 1,
      cartItems: [
        CartItemDTO(
          id: 1,
          cartId: 1,
          productId: 1,
          quantity: 5,
          product: productDTO
        )
      ]
    )
    cartPublisher.send(updatedCart)
    
//    try await Task.sleep(for: .milliseconds(100))
    
    // Then
    #expect(sut.quantityInCart == 5)
  }

  @Test
  func resetsQuantityToZeroWhenProductRemovedFromCart() async throws {
    // Given
    let cartWithProduct = CartDTO(
      id: 1,
      cartItems: [
        CartItemDTO(
          id: 1,
          cartId: 1,
          productId: 1,
          quantity: 3,
          product: productDTO
        )
      ]
    )
    
    // Start with product in cart
    cartPublisher.send(cartWithProduct)
//    try await Task.sleep(for: .milliseconds(100))
    #expect(sut.quantityInCart == 3)
    
    // When - publish empty cart
    let emptyCart = CartDTO(id: 1, cartItems: [])
    cartPublisher.send(emptyCart)
    
//    try await Task.sleep(for: .milliseconds(100))
    
    // Then
    #expect(sut.quantityInCart == 0)
  }

  @Test
  func ignoresOtherProductsInCart() async throws {
    // Given
    let cartWithOtherProducts = CartDTO(
      id: 1,
      cartItems: [
        CartItemDTO(
          id: 2,
          cartId: 1,
          productId: 2,
          quantity: 5,
          product: productDTO
        ),
        CartItemDTO(
          id: 3,
          cartId: 1,
          productId: 3,
          quantity: 10,
          product: productDTO
        )
      ]
    )
    
    // When - publish cart with other products
    cartPublisher.send(cartWithOtherProducts)
//    try await Task.sleep(for: .milliseconds(100))
    
    // Then - quantity should remain 0 since product ID 1 is not in cart
    #expect(sut.quantityInCart == 0)
  }
}
