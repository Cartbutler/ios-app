//
//  CartDTOTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-10-17.
//

import Foundation
import Testing
@testable import CartButler

@Suite("CartDTO Tests")
struct CartDTOTests {
  
  // Helper function to create mock ProductDTO
  private func createMockProduct(id: Int, name: String = "Product", price: Double = 10.0) -> ProductDTO {
    ProductDTO(
      productId: id,
      productName: name,
      description: "Description",
      price: price,
      stock: 100,
      categoryId: 1,
      imagePath: "/path/image.jpg",
      createdAt: Date(),
      categoryName: "Category",
      stores: nil,
      minPrice: price,
      maxPrice: price
    )
  }
  
  // Helper function to create mock CartItemDTO
  private func createMockCartItem(
    id: Int,
    productId: Int,
    quantity: Int,
    cartId: Int = 1
  ) -> CartItemDTO {
    CartItemDTO(
      id: id,
      cartId: cartId,
      productId: productId,
      quantity: quantity,
      product: createMockProduct(id: productId)
    )
  }
  
  @Test("Empty cart returns zero quantity for any product")
  func emptyCartQuantity() {
    let cart = CartDTO(id: 1, cartItems: [])
    
    #expect(cart.quantity(for: 1) == 0)
    #expect(cart.quantity(for: 999) == 0)
    #expect(cart.isEmpty == true)
    #expect(cart.totalQuantity == 0)
  }
  
  @Test("Cart with single item returns correct quantity")
  func singleItemQuantity() {
    let cartItem = createMockCartItem(id: 1, productId: 42, quantity: 3)
    let cart = CartDTO(id: 1, cartItems: [cartItem])
    
    #expect(cart.quantity(for: 42) == 3)
    #expect(cart.quantity(for: 1) == 0)
    #expect(cart.quantity(for: 999) == 0)
    #expect(cart.totalQuantity == 3)
  }
  
  @Test("Cart with multiple items returns correct quantities")
  func multipleItemsQuantity() {
    let cartItems = [
      createMockCartItem(id: 1, productId: 10, quantity: 2),
      createMockCartItem(id: 2, productId: 20, quantity: 5),
      createMockCartItem(id: 3, productId: 30, quantity: 1)
    ]
    let cart = CartDTO(id: 1, cartItems: cartItems)
    
    #expect(cart.quantity(for: 10) == 2)
    #expect(cart.quantity(for: 20) == 5)
    #expect(cart.quantity(for: 30) == 1)
    #expect(cart.quantity(for: 999) == 0)
    #expect(cart.totalQuantity == 8)
  }
  
  @Test("Contains method correctly identifies products in cart")
  func containsProduct() {
    let cartItems = [
      createMockCartItem(id: 1, productId: 10, quantity: 2),
      createMockCartItem(id: 2, productId: 20, quantity: 5)
    ]
    let cart = CartDTO(id: 1, cartItems: cartItems)
    
    #expect(cart.contains(productId: 10) == true)
    #expect(cart.contains(productId: 20) == true)
    #expect(cart.contains(productId: 30) == false)
    #expect(cart.contains(productId: 999) == false)
  }
  
  @Test("Empty cart contains no products")
  func emptyCartContains() {
    let cart = CartDTO(id: 1, cartItems: [])
    
    #expect(cart.contains(productId: 1) == false)
    #expect(cart.contains(productId: 999) == false)
  }
  
  @Test("Item method returns correct cart item")
  func itemForProduct() {
    let cartItem1 = createMockCartItem(id: 1, productId: 10, quantity: 2)
    let cartItem2 = createMockCartItem(id: 2, productId: 20, quantity: 5)
    let cart = CartDTO(id: 1, cartItems: [cartItem1, cartItem2])
    
    let item = cart.item(for: 10)
    #expect(item?.productId == 10)
    #expect(item?.quantity == 2)
    #expect(item?.id == 1)
    
    let missingItem = cart.item(for: 999)
    #expect(missingItem == nil)
  }
  
  @Test("Total quantity calculates sum of all items",
        arguments: [
          (items: [], expected: 0),
          (items: [1], expected: 1),
          (items: [2, 3, 4], expected: 9),
          (items: [10, 20, 30, 5], expected: 65)
        ])
  func totalQuantityCalculation(items: [Int], expected: Int) {
    let cartItems = items.enumerated().map { index, quantity in
      createMockCartItem(id: index, productId: index * 10, quantity: quantity)
    }
    let cart = CartDTO(id: 1, cartItems: cartItems)
    
    #expect(cart.totalQuantity == expected)
  }
  
  @Test("Cart with zero quantity items")
  func zeroQuantityItems() {
    // This is an edge case - normally shouldn't happen, but good to test
    let cartItems = [
      createMockCartItem(id: 1, productId: 10, quantity: 0),
      createMockCartItem(id: 2, productId: 20, quantity: 3)
    ]
    let cart = CartDTO(id: 1, cartItems: cartItems)
    
    #expect(cart.quantity(for: 10) == 0)
    #expect(cart.contains(productId: 10) == true) // Item exists even with 0 quantity
    #expect(cart.quantity(for: 20) == 3)
    #expect(cart.totalQuantity == 3)
  }
  
  @Test("Large quantity values")
  func largeQuantityValues() {
    let cartItems = [
      createMockCartItem(id: 1, productId: 10, quantity: Int.max - 1)
    ]
    let cart = CartDTO(id: 1, cartItems: cartItems)
    
    #expect(cart.quantity(for: 10) == Int.max - 1)
    #expect(cart.totalQuantity == Int.max - 1)
  }
}
