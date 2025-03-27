//
//  StoreDetailsView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import SwiftUI

struct StoreDetailsView: View {
  let result: ShoppingResultsDTO

  var body: some View {
    VStack(spacing: 16) {
      storeHeader
      productsList
    }
    .navigationTitle(result.storeName)
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
  }

  private var storeHeader: some View {
    VStack {
      AsyncImageView(imagePath: result.storeImage)
        .frame(width: 200)
        .padding(.bottom)
      HStack(alignment: .bottom) {
        Text("\(result.products.count) items")
          .font(.subheadline)
          .foregroundStyle(.secondaryVariant)
        Spacer()
        Text(Formatter.currency(with: result.total))
          .font(.title)
          .fontWeight(.bold)
          .foregroundStyle(.primaryVariant)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.themeSurface)
    )
    .padding(.horizontal)
  }

  private var productsList: some View {
    List {
      ForEach(result.products) { product in
        productRow(for: product)
      }
    }
    .listStyle(.plain)
  }

  private func productRow(for product: ShoppingResultsDTO.ProductDTO) -> some View {
    HStack {
      VStack(alignment: .leading) {
        Text(product.productName)
          .font(.headline)
        Text("Quantity: \(product.quantity)")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      Spacer()

      Text(Formatter.currency(with: product.total))
        .font(.title3)
        .fontWeight(.semibold)
    }
  }
}
