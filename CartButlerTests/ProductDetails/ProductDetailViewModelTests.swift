//
//  ProductDetailViewModelTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-21.
//

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
  private let sut: ProductDetailsViewModel

  init() {
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

  // MARK: - Formatting price

  @Test
  func formattedPriceWithRange() {
    // Given
    let product = buildProduct(price: 4.99, minPrice: 3.99, maxPrice: 5.99)
    // When
    let result = sut.formattedPrice(from: product)
    // Then
    #expect(result == "$3.99 - $5.99")
  }

  @Test
  func formattedPriceWithoutRange() {
    // Given
    let product = buildProduct(price: 4.99, minPrice: nil, maxPrice: nil)
    // When
    let result = sut.formattedPrice(from: product)
    // Then
    #expect(result == "$4.99")
  }

  @Test
  func formattedPriceWithSameRange() {
    // Given
    let product = buildProduct(price: 4.99, minPrice: 3.99, maxPrice: 3.99)
    // When
    let result = sut.formattedPrice(from: product)
    // Then
    #expect(result == "$4.99")
  }

  @Test
  func formattedPriceOutOfRange() {
    // Given
    let product = buildProduct(price: 3.99, minPrice: 4.99, maxPrice: 5.99)
    // When
    let result = sut.formattedPrice(from: product)
    // Then
    #expect(result == "$4.99 - $5.99")
  }

  @Test
  func formattedPriceWithInvalidRange() {
    // Given
    let product = buildProduct(price: 4.99, minPrice: 5.99, maxPrice: 3.99)
    // When
    let result = sut.formattedPrice(from: product)
    // Then
    #expect(result == "$4.99")
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

  // MARK: - Helpers

  private func buildProduct(price: Double, minPrice: Double?, maxPrice: Double?) -> ProductDTO {
    return ProductDTO(
      productId: 1,
      productName: "product",
      description: "description",
      price: price,
      stock: 10,
      categoryId: 1,
      imagePath: "",
      createdAt: Date(),
      categoryName: "category",
      stores: [],
      minPrice: minPrice,
      maxPrice: maxPrice
    )
  }
}
