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
  
  @ViewBuilder
  private var cartActionSection: some View {
    if viewModel.quantityInCart > 0 {
      // Show quantity picker with cart button
      HStack(spacing: 12) {
        quantityPicker
        cartButton
      }
      .padding(.horizontal, 16)
    } else {
      // Show add to cart button only
      addToCartButton
    }
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

  private var addToCartButton: some View {
    Button {
      Task { await viewModel.addToCart() }
    } label: {
      Label("Add to Cart", systemImage: "cart")
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    .foregroundStyle(.onPrimary)
    .buttonStyle(.borderedProminent)
  }
  
  @ViewBuilder
  private var cartButton: some View {
    let isUpdateNeeded = selectedQuantity != viewModel.quantityInCart
    
    Button {
      Task { await viewModel.updateCartQuantity(to: selectedQuantity) }
    } label: {
      Label(
        isUpdateNeeded ? "Update Cart" : "In Cart",
        systemImage: isUpdateNeeded ? "cart.fill" : "cart.circle.fill"
      )
      .frame(maxWidth: .infinity)
      .padding(8)
    }
    .foregroundStyle(.onPrimary)
    .buttonStyle(.borderedProminent)
    .disabled(!isUpdateNeeded)
  }

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
}
