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
    minPrice: 4.99,
    maxPrice: 5.99,
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

  private let shoppingResultsDTO = ShoppingResultsDTO(
    storeId: 1,
    storeName: "Test Store",
    storeLocation: "Test Location",
    storeAddress: "Test Address",
    storeImage: "",
    products: [
      .init(
        productId: 1,
        productName: "Test Product",
        price: 9.99,
        quantity: 2
      )
    ],
    total: 19.98
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
      .get(path: .value("search"), queryParameters: .value(["category_id": "1"]))
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
  func fetchCartSuccess() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 4, product: .empty)]
    )
    given(mockAPIClient)
      .get(path: .value("cart"), queryParameters: .matching { $0?["user_id"] != nil })
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchCart()

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchCartFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> CartDTO in
        throw NetworkError.invalidResponse
      }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.fetchCart()
    }
  }

  @Test
  func addToCartSuccess() async throws {
    // Given
    let expectedResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 4, product: .empty)]
    )
    let matcher: (AddToCartDTO) -> Bool = {
      $0.productId == expectedResponse.cartItems.first?.productId
        && $0.quantity == expectedResponse.cartItems.first?.quantity
    }
    given(mockAPIClient)
      .post(path: .value("cart"), body: .matching(matcher))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.addToCart(productId: 3, quantity: 4)

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

  // MARK: - Shopping Results

  @Test
  func fetchShoppingResultsSuccess() async throws {
    // Given
    let expectedResponse = [shoppingResultsDTO]
    let matcher: ([String: String]?) -> Bool = {
      $0?["cart_id"] == "123"
        && $0?["user_id"] != nil
        && $0?["store_ids"] == nil
        && $0?["radius"] == nil
        && $0?["lat"] == nil
        && $0?["long"] == nil
    }
    given(mockAPIClient)
      .get(path: .value("shopping-results"), queryParameters: .matching(matcher))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchShoppingResults(cartId: 123)

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchShoppingResultsWithFiltersSuccess() async throws {
    // Given
    let expectedResponse = [shoppingResultsDTO]
    let matcher: ([String: String]?) -> Bool = {
      $0?["cart_id"] == "123"
        && $0?["user_id"] != nil
        && $0?["store_ids"] == "1,2"
        && $0?["user_location"] == "1.2,2.3"
    }
    given(mockAPIClient)
      .get(path: .value("shopping-results"), queryParameters: .matching(matcher))
      .willReturn(expectedResponse)

    // When
    let result = try await sut.fetchShoppingResults(
      cartId: 123,
      storeIds: [1, 2],
      radius: 12.345,
      lat: 1.2,
      long: 2.3
    )

    // Then
    #expect(result == expectedResponse)
  }

  @Test
  func fetchShoppingResultsFailure() async throws {
    // Given
    given(mockAPIClient)
      .get(path: .any, queryParameters: .any)
      .willProduce { _, _ -> [ShoppingResultsDTO] in
        throw NetworkError.invalidResponse
      }

    // Then
    await #expect(throws: NetworkError.invalidResponse) {
      // When
      _ = try await sut.fetchShoppingResults(cartId: 123)
    }
  }
}
