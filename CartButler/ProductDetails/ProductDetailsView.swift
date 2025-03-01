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
    .task {
      await viewModel.fetchProduct()
    }
  }

  private func productView(product: ProductDTO) -> some View {
    ScrollView {
      VStack(alignment: .leading) {
        AsyncImageView(imagePath: product.imagePath)

        productInfo(with: product)
        Spacer()
      }
    }
  }

  private func productInfo(with product: ProductDTO) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(product.productName)
        .font(.largeTitle)
        .fontWeight(.bold)
      Text(viewModel.formattedPrice(from: product))
        .font(.title2)
        .fontWeight(.semibold)
      Text(product.description)
        .font(.body)
      Text("Stores")
        .font(.title2)
        .fontWeight(.bold)
        .padding(.top)
      ForEach(product.stores) { store in
        storePriceCard(store)
      }
    }
    .padding(.horizontal)
  }

  private func storePriceCard(_ store: StoreDTO) -> some View {
    HStack {
      Text(store.storeName)
        .font(.headline)
        .fontWeight(.semibold)
      Spacer()
      Text(Formatter.currency(from: store.price))
        .font(.subheadline)
    }
  }
}
