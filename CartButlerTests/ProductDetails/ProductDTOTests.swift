//
//  ProductDTOTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-15.
//
import Foundation
import Testing

@testable import CartButler

struct ProductDTOTests {

  // MARK: - Formatting price

  @Test
  func formattedPriceWithRange() {
    // Given
    let product = buildProduct(price: 4.99, minPrice: 3.99, maxPrice: 5.99)
    // When
    let result = product.formattedPrice
    // Then
    #expect(result == "$3.99 - $5.99")
  }

  @Test
  func formattedPriceWithoutRange() {
    // Given
    let product = buildProduct(price: 4.99, minPrice: nil, maxPrice: nil)
    // When
    let result = product.formattedPrice
    // Then
    #expect(result == "$4.99")
  }

  @Test
  func formattedPriceWithSameRange() {
    // Given
    let product = buildProduct(price: 4.99, minPrice: 3.99, maxPrice: 3.99)
    // When
    let result = product.formattedPrice
    // Then
    #expect(result == "$4.99")
  }

  @Test
  func formattedPriceOutOfRange() {
    // Given
    let product = buildProduct(price: 3.99, minPrice: 4.99, maxPrice: 5.99)
    // When
    let result = product.formattedPrice
    // Then
    #expect(result == "$4.99 - $5.99")
  }

  @Test
  func formattedPriceWithInvalidRange() {
    // Given
    let product = buildProduct(price: 4.99, minPrice: 5.99, maxPrice: 3.99)
    // When
    let result = product.formattedPrice
    // Then
    #expect(result == "$4.99")
  }

  // MARK: - Helpers

  private func buildProduct(price: Double, minPrice: Double?, maxPrice: Double?) -> ProductDTO {
    ProductDTO(
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

extension ProductDTO {
  static var empty: ProductDTO {
    ProductDTO(
      productId: 0,
      productName: "",
      description: "",
      price: 0,
      stock: 0,
      categoryId: 0,
      imagePath: "",
      createdAt: Date(),
      categoryName: "",
      stores: [],
      minPrice: nil,
      maxPrice: nil
    )
  }
}
