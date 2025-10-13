//
//  ProductTile.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-12.
//

import SwiftUI

struct ProductTile: View {
  let product: BasicProductDTO

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.themeSurface)
        .stroke(.themePrimary, lineWidth: 1)
      HStack {
        Spacer()
        VStack {
          Spacer()
          AsyncImageView(imagePath: product.imagePath)
          Text(product.productName)
            .font(.headline)
            .foregroundColor(.onSurface)
          Text(Formatter.currency(from: product.minPrice, to: product.maxPrice))
            .font(.subheadline)
            .foregroundColor(.onSurface)
          Spacer()
        }
        Spacer()
      }
      .padding()
    }
  }
}

#Preview("ProductTile") {
  ProductTile(
    product: BasicProductDTO(
      productId: 1,
      productName: "Product 1",
      minPrice: 1.99,
      maxPrice: 2.99,
      imagePath: "https://storage.googleapis.com/southern-shard-449119-d4.appspot.com/Apple.png")
  )
  .frame(width: 200, height: 200)
}
