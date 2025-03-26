//
//  MainViewModelTests.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-11.
//

import Combine
import Foundation
import Mockable
import Testing

@testable import CartButler

@MainActor
struct MainViewModelTests {

  private let mockCartRepository = MockCartRepositoryProvider()
  private let sut: MainViewModel

  init() {
    sut = MainViewModel(cartRepository: mockCartRepository)
  }

  @Test
  func viewDidAppearShouldRefreshCart() async throws {
    // Given
    let cartSubject = PassthroughSubject<CartDTO?, Never>()
    let expectedResponse = CartDTO(
      id: 1,
      cartItems: [.init(id: 1, cartId: 2, productId: 3, quantity: 4, product: .empty)]
    )
    given(mockCartRepository)
      .cartPublisher
      .willReturn(cartSubject.eraseToAnyPublisher())

    given(mockCartRepository)
      .refreshCart()
      .willProduce {
        cartSubject.send(expectedResponse)
      }

    #expect(sut.cartCount == 0)

    // When
    sut.viewDidAppear()

    // Then
    let cartCount = await sut.$cartCount.values.first { $0 != 0 }
    #expect(cartCount == 1)
  }

}
