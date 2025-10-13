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
      addToCartButton
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
    .padding(.horizontal, 16)
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
