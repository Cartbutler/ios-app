//
//  APIServiceTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-05.
//

import Foundation
import Mockable
import Testing

@testable import CartButler

struct APIServiceTests {

  private let mockAPIClient = MockAPIClientProvider()
  private let sut: APIService
  private let basicProductDTO = BasicProductDTO(
    productId: 1,
    productName: "product",
    price: 4.99,
    imagePath: ""
  )
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

  init() {
    sut = APIService(apiClient: mockAPIClient)
  }

  // MARK: - Categories

  @Test
  func fetchCategoriesSuccess() async throws {
    // Given
    let expectedResponse = [
      CategoryDTO(categoryId: 1, categoryName: "category", imagePath: "http://path.to/image")
    ]
    given(mockAPIClient)
      .get(path: .value("categories"), queryParameters: .value(nil))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchCategories()

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchCategoriesFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> [CategoryDTO] in
        throw NetworkError.invalidResponse
      }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.fetchCategories()
    }
  }

  // MARK: - Suggestions

  @Test
  func fetchSuggestionsSuccess() async throws {
    // Given
    let expectedResponse = [SuggestionDTO(id: 1, name: "suggestion", priority: 1)]
    given(mockAPIClient)
      .get(path: .value("suggestions"), queryParameters: .value(["query": "my query"]))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchSuggestions(query: "my query")

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchSuggestionsFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> [SuggestionDTO] in
        throw NetworkError.invalidResponse
      }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.fetchSuggestions(query: "my query")
    }
  }

  // MARK: - Products by query

  @Test
  func fetchProductsByQuerySuccess() async throws {
    // Given
    let expectedResponse = [basicProductDTO]
    given(mockAPIClient)
      .get(path: .value("search"), queryParameters: .value(["query": "a"]))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchProducts(query: "a")

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchProductsByQueryFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> [BasicProductDTO] in
        throw NetworkError.invalidResponse
      }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.fetchProducts(query: "a")
    }
  }

  // MARK: - Product by categoryID

  @Test
  func fetchProducstByCategorySuccess() async throws {
    // Given
    let expectedResponse = [basicProductDTO]
    given(mockAPIClient)
      .get(path: .value("search"), queryParameters: .value(["categoryID": "1"]))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchProducts(categoryID: 1)

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchProductsByCategoryFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> [BasicProductDTO] in
        throw NetworkError.invalidResponse
      }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.fetchProducts(categoryID: 1)
    }
  }

  // MARK: - Product by ID

  @Test
  func fetchProductSuccess() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .value("product"), queryParameters: .value(["id": "1"]))
      .willReturn(productDTO)

    // When
    let result = try await sut.fetchProduct(id: 1)

    // Then
    #expect(result == productDTO)
  }

  @Test
  func fetchProductFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> ProductDTO in
        throw NetworkError.invalidResponse
      }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.fetchProduct(id: 1)
    }
  }

  // MARK: Cart

  @Test
  func addToCartSuccess() async throws {
    // Given
    let expectedResponse = CartDTO(id: 1, userId: "abcd", productId: 1, quantity: 2)
    let matcher: (AddToCartDTO) -> Bool = {
      $0.productId == expectedResponse.productId && $0.quantity == expectedResponse.quantity
    }
    given(mockAPIClient)
      .post(path: .value("cart"), body: .matching(matcher))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.addToCart(productId: 1, quantity: 2)

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func addToCartFailure() async throws {
    // Given
    given(mockAPIClient)
      .post(path: .any, body: .any)
      .willProduce { (_: String, _: AddToCartDTO) -> CartDTO in
        throw NetworkError.invalidResponse
      }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.addToCart(productId: 1, quantity: 2)
    }
  }
}
