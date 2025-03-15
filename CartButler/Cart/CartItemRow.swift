//
//  CartItemRow.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-15.
//
import SwiftUI

struct CartItemRow: View {
  let item: CartItemDTO
  let onIncrement: () -> Void
  let onDecrement: () -> Void

  var body: some View {
    HStack {
      AsyncImageView(imagePath: item.product.imagePath)
        .frame(width: 60, height: 60)
      productInfo
      Spacer()
      quantityPanel
    }
    .foregroundColor(.onSurface)
  }

  private var productInfo: some View {
    VStack(alignment: .leading) {
      Text(item.product.productName)
        .font(.headline)
      Text(item.product.formattedPrice)
        .font(.subheadline)
    }
  }

  private var quantityPanel: some View {
    HStack {
      quantityButton(imageName: "minus.circle.fill", action: onDecrement)
      Text("\(item.quantity)")
        .frame(minWidth: 30)
        .font(.title2)
      quantityButton(imageName: "plus.circle.fill", action: onIncrement)
    }
  }

  private func quantityButton(imageName: String, action: @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      Image(systemName: imageName)
        .font(.title2)
    }
    .foregroundStyle(.primaryVariant)
    .buttonStyle(.borderless)
  }
}
