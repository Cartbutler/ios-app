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
    productStore: []
  )

  private let mockService = MockAPIServiceProvider()
  private let sut: ProductDetailsViewModel

  init() {
    sut = ProductDetailsViewModel(apiService: mockService, productID: productDTO.id)
  }

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
}
