//
//  ProductDetailsView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-18.
//

import SwiftUI

struct ProductDetailsView: View {

  private let product: BasicProductDTO
  @StateObject private var viewModel: ProductDetailsViewModel
  @State private var selectedQuantity = 0
  @State private var isPerformingAction = false

  init(product: BasicProductDTO) {
    self.product = product
    _viewModel = StateObject(wrappedValue: ProductDetailsViewModel(productID: product.id))
  }

  var body: some View {
    Group {
      if let product = viewModel.product {
        productView(product: product)
      } else if viewModel.isLoading {
        ProgressView("Loading product...")
      } else {
        ErrorView(message: viewModel.errorMessage ?? "Error") {
          Task { await viewModel.fetchProduct() }
        }
      }
    }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .navigationTitle(product.productName)
    .alert(viewModel.alertMessage ?? "", isPresented: $viewModel.showAlert) {
      Button("OK") {
        viewModel.alertMessage = nil
      }
    }
    .task {
      await viewModel.fetchProduct()
    }
    .onChange(of: viewModel.quantityInCart, initial: true) { _, newValue in
      selectedQuantity = newValue
    }
  }

  private func productView(product: ProductDTO) -> some View {
    Group {
      ScrollView {
        VStack(alignment: .leading) {
          AsyncImageView(imagePath: product.imagePath)
          productInfo(with: product)
          Spacer()
        }
      }
      cartActionSection
        .padding(.bottom, 8)
    }
    .ignoresSafeArea(edges: .top)
  }

  private func productInfo(with product: ProductDTO) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(product.productName)
        .font(.largeTitle)
        .fontWeight(.bold)
      Text(product.formattedPrice)
        .font(.title2)
        .fontWeight(.semibold)
      Text(product.description)
        .font(.body)
      Text("Stores")
        .font(.title2)
        .fontWeight(.bold)
        .padding(.top)
      ForEach(product.stores ?? []) { store in
        storePriceCard(store)
      }
    }
    .padding(.horizontal)
  }
  
  private var currentCartState: CartState {
    if viewModel.quantityInCart == 0 {
      .notInCart
    } else if selectedQuantity == 0 {
      .removing
    } else if selectedQuantity != viewModel.quantityInCart {
      .updating
    } else {
      .inCart
    }
  }
  
  @ViewBuilder
  private var cartActionSection: some View {
    Group {
      switch currentCartState {
      case .notInCart:
        cartActionButton(state: .notInCart) {
          await performCartAction {
            await viewModel.addToCart()
          }
        }
      case .inCart, .updating, .removing:
        HStack(spacing: 12) {
          quantityPicker
            .disabled(isPerformingAction)
          cartActionButton(state: currentCartState) {
            await performCartAction {
              await viewModel.updateCartQuantity(to: selectedQuantity)
            }
          }
        }
      }
    }
    .padding(.horizontal, 16)
  }
  
  private var quantityPicker: some View {
    Picker("Quantity", selection: $selectedQuantity) {
      ForEach(0...10, id: \.self) { quantity in
        Text("\(quantity)").tag(quantity)
      }
    }
    .frame(minWidth: 100)
    .pickerStyle(.menu)
    .tint(.primary)
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .background(Color(.themeSurface))
    .cornerRadius(8)
  }
  
  @ViewBuilder
  private func cartActionButton(state: CartState, action: @escaping () async -> Void) -> some View {
    Button {
      Task { await action() }
    } label: {
      HStack {
        if isPerformingAction {
          ProgressView()
        }
        Label(state.buttonTitle, systemImage: state.buttonIcon)
      }
      .frame(maxWidth: .infinity)
      .padding(8)
    }
    .foregroundStyle(isPerformingAction || state.isDisabled ? .onSurface : .onPrimary)
    .buttonStyle(.borderedProminent)
    .disabled(state.isDisabled || isPerformingAction)
  }
  
  @ViewBuilder
  private func storePriceCard(_ store: StoreDTO) -> some View {
    HStack {
      AsyncImageView(imagePath: store.storeImage, style: .original)
        .frame(width: 40, height: 40)
      Text(store.storeName)
        .font(.headline)
        .fontWeight(.semibold)
      Spacer()
      Text(Formatter.currency(with: store.price))
        .font(.subheadline)
    }
  }
  
  private func performCartAction(_ action: () async -> Void) async {
    isPerformingAction = true
    await action()
    isPerformingAction = false
  }
}

// MARK: - Cart State Management

private enum CartState {
  case notInCart
  case inCart
  case updating
  case removing
  
  var buttonTitle: LocalizedStringKey {
    switch self {
    case .notInCart: "Add to Cart"
    case .inCart: "In Cart"
    case .updating: "Update Cart"
    case .removing: "Remove from Cart"
    }
  }
  
  var buttonIcon: String {
    switch self {
    case .notInCart: "cart"
    case .inCart: "cart.circle.fill"
    case .updating: "cart.fill"
    case .removing: "cart.badge.minus"
    }
  }
  
  var isDisabled: Bool {
    self == .inCart
  }
}
