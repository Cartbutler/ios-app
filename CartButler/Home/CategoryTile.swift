//
//  CategoryView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-26.
//
import SwiftUI

struct CategoryTile: View {
  let category: Category

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.themeSurface)
        .stroke(.themePrimary, lineWidth: 1)
      HStack {
        Spacer()
        VStack {
          Spacer()
          AsyncImageView(imagePath: category.imagePath)
          Text(category.name)
            .font(.headline)
            .foregroundColor(.onSurface)
          Spacer()
        }
        Spacer()
      }
      .padding()
    }
  }
}

#Preview("CategoryTile") {
  CategoryTile(
    category: Category(
      id: 1,
      name: "Category 1",
      imagePath: "https://storage.googleapis.com/southern-shard-449119-d4.appspot.com/Apple.png"
    )
  )
  .frame(width: 200, height: 200)
}
