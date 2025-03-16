//
//  CartView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import SwiftUI

struct CartView: View {
  @StateObject private var viewModel = CartViewModel()

  var body: some View {

    NavigationStack {
      withAnimation {
        Group {
          if viewModel.cart.isEmpty {
            emptyCartView
          } else {
            cartItemsList
          }
        }
      }
      .navigationTitle("Cart")
      .navigationBarTitleDisplayMode(.inline)
    }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .alert(viewModel.errorMessage ?? "", isPresented: $viewModel.showAlert) {
      Button("OK") {
        viewModel.errorMessage = nil
      }
    }
    .onAppear {
      viewModel.viewDidAppear()
    }
  }

  private var emptyCartView: some View {
    VStack {
      Image(systemName: "cart")
        .font(.largeTitle)
      Text("Your cart is empty")
        .font(.headline)
        .padding(.top)
    }
  }

  private var cartItemsList: some View {
    List {
      ForEach(viewModel.cart.cartItems) { item in
        CartItemRow(
          item: item,
          onIncrement: {
            Task { await viewModel.incrementQuantity(for: item.productId) }
          },
          onDecrement: {
            Task { await viewModel.decrementQuantity(for: item.productId) }
          }
        )
      }
    }
    .listStyle(.plain)
  }
}
