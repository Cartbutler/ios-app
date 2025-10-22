//
//  CartView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import SwiftUI

struct CartView: View {
  @EnvironmentObject private var coordinator: TabCoordinator
  @StateObject private var viewModel = CartViewModel()

  var body: some View {
    NavigationStack(path: $coordinator.cartPath) {
      withAnimation {
        Group {
          if let cart = viewModel.cart {
            VStack {
              cartItemsList(with: cart.cartItems)
              Spacer()
              shoppingResultsButton
                .padding(.bottom, 8)
            }
          } else {
            emptyCartView
          }
        }
      }
      .withAppNavigation()
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

  private func cartItemsList(with cartItems: [CartItemDTO]) -> some View {
    List {
      ForEach(cartItems) { item in
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
      .onDelete { indexSet in
        Task { await viewModel.removeItemsFromIndexSet(indexSet) }
      }
    }
    .listStyle(.plain)
  }

  private var shoppingResultsButton: some View {
    Button {
      coordinator.navigate(to: AppDestination.shoppingResults)
    } label: {
      Label("Compare Prices", systemImage: "cart.badge.questionmark")
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    .foregroundStyle(.onPrimary)
    .buttonStyle(.borderedProminent)
    .padding(.horizontal, 16)
  }
}
