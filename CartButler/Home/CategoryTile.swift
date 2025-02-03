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
          Text(category.icon)
            .font(.largeTitle)
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
  CategoryTile(category: Category(id: 1, name: "Category 1", icon: "🍔"))
    .frame(width: 200, height: 200)
}
