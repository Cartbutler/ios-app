//
//  ProductDetailsView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-18.
//

import SwiftUI

struct ProductDetailsView: View {
  let product: ProductDTO

  var body: some View {
    VStack(spacing: 0) {
      productView
      Button(action: {
        print("Add to Cart")
      }) {
        Label("Add to Cart", systemImage: "cart")
          .padding(8)
      }
      .buttonStyle(.borderedProminent)
    }
    .navigationTitle(product.productName)
  }

  private var productView: some View {
    ScrollView {
      VStack(alignment: .leading) {

        AsyncImage(url: URL(string: product.imagePath)) { phase in
          switch phase {
          case .empty:
            ProgressView()
          case .success(let image):
            image.resizable().aspectRatio(contentMode: .fit)
          case .failure:
            Image(systemName: "photo.circle.fill")
              .font(.largeTitle)
              .padding()
          @unknown default:
            EmptyView()
          }
        }

        VStack(alignment: .leading, spacing: 8) {
          Text(product.productName)
            .font(.largeTitle)
            .fontWeight(.bold)
          Text(Formatter.currency(from: product.price))
            .font(.title2)
            .fontWeight(.semibold)
          Text(product.description)
            .font(.body)
        }
        .padding(.horizontal)

        Spacer()
      }
    }
  }
}

#Preview("ProductDetailsView Light") {
  ProductDetailsView(
    product: ProductDTO(
      productId: 1,
      productName: "Product 1",
      description: "This is the description of Product 1",
      price: 10.0,
      stock: 10,
      categoryId: 1,
      imagePath: "https://storage.googleapis.com/southern-shard-449119-d4.appspot.com/Apple.png",
      createdAt: Date()
    )
  )
}

#Preview("ProductDetailsView Dark") {
  ProductDetailsView(
    product: ProductDTO(
      productId: 1,
      productName: "Product 1",
      description: "This is the description of Product 1",
      price: 10.0,
      stock: 10,
      categoryId: 1,
      imagePath: "https://storage.googleapis.com/southern-shard-449119-d4.appspot.com/Apple.png",
      createdAt: Date()
    )
  )
  .preferredColorScheme(.dark)
}
