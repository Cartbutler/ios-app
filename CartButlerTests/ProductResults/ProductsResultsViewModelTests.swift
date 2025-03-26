//
//  ProductsResultsViewModelTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-13.
//
import Combine
import Foundation
import Mockable
import Testing

@testable import CartButler

@MainActor
struct ProductsResultsViewModelTests {

  private let basicProductDTO = BasicProductDTO(
    productId: 1,
    productName: "product",
    minPrice: 4.99,
    maxPrice: 5.99,
    imagePath: ""
  )

  private let mockService = MockAPIServiceProvider()

  @Test
  func fetchProductsShouldSetLoadingState() async throws {
    // Given
    given(mockService)
      .fetchProducts(query: .any)
      .willReturn([])

    let sut = ProductsResultsViewModel(
      apiService: mockService,
      searchType: .query("test")
    )
    #expect(sut.isLoading == false)

    await confirmation { loadStarted in
      let subscription = sut.$isLoading.sink { isLoading in
        // Then
        if isLoading {
          loadStarted.confirm()
        }
      }
      // When
      await sut.fetchProducts()
      subscription.cancel()
    }

    // Then
    #expect(sut.isLoading == false)
  }

  @Test
  func fetchProductsBySearchQuerySuccess() async throws {
    // Given
    let expectedProducts = [basicProductDTO]
    given(mockService)
      .fetchProducts(query: .value("test"))
      .willReturn(expectedProducts)

    let sut = ProductsResultsViewModel(
      apiService: mockService,
      searchType: .query("test")
    )
    #expect(sut.errorMessage == nil)
    #expect(sut.products.isEmpty)

    // When
    await sut.fetchProducts()

    // Then
    #expect(sut.isLoading == false)
    #expect(sut.errorMessage == nil)
    #expect(sut.products == expectedProducts)
  }

  @Test
  func fetchProductsBySearchQueryFailure() async throws {
    // Given
    given(mockService)
      .fetchProducts(query: .any)
      .willThrow(NetworkError.invalidResponse)

    let sut = ProductsResultsViewModel(
      apiService: mockService,
      searchType: .query("test")
    )
    #expect(sut.errorMessage == nil)
    #expect(sut.products.isEmpty)

    // When
    await sut.fetchProducts()

    // Then
    #expect(sut.isLoading == false)
    #expect(sut.errorMessage != nil)
    #expect(sut.products.isEmpty)
  }

  @Test
  func fetchProductsByCategorySuccess() async throws {
    // Given
    let category = Category(id: 1, name: "cateory", imagePath: "http://path.to/image")
    let expectedProducts = [basicProductDTO]
    given(mockService)
      .fetchProducts(categoryID: .value(category.id))
      .willReturn(expectedProducts)

    let sut = ProductsResultsViewModel(
      apiService: mockService,
      searchType: .category(category)
    )
    #expect(sut.errorMessage == nil)
    #expect(sut.products.isEmpty)

    // When
    await sut.fetchProducts()

    // Then
    #expect(sut.isLoading == false)
    #expect(sut.errorMessage == nil)
    #expect(sut.products == expectedProducts)
  }

  @Test
  func fetchProductsByCategoryFailure() async throws {
    // Given
    let category = Category(id: 1, name: "cateory", imagePath: "http://path.to/image")
    given(mockService)
      .fetchProducts(categoryID: .any)
      .willThrow(NetworkError.invalidResponse)

    let sut = ProductsResultsViewModel(
      apiService: mockService,
      searchType: .category(category)
    )
    #expect(sut.errorMessage == nil)
    #expect(sut.products.isEmpty)

    // When
    await sut.fetchProducts()

    // Then
    #expect(sut.errorMessage != nil)
    #expect(sut.products.isEmpty)
  }

  @Test
  func navigationTitleForSearchQuery() throws {
    // Given
    let query = "test"
    // When
    let sut = ProductsResultsViewModel(
      apiService: mockService,
      searchType: .query(query)
    )
    // Then
    #expect(sut.navigationTitle == "Results for \"\(query)\"")
  }

  @Test
  func navigationTitleForCategory() throws {
    // Given
    let category = Category(id: 1, name: "cateory", imagePath: "http://path.to/image")
    // When
    let sut = ProductsResultsViewModel(
      apiService: mockService,
      searchType: .category(category)
    )
    // Then
    #expect(sut.navigationTitle == category.name)
  }
}
