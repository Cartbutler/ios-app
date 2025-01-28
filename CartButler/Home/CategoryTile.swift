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
    HStack {
      Spacer()
      VStack {
        Spacer()
        Text(category.icon)
          .font(.largeTitle)
        Text(category.name)
          .font(.caption)
        Spacer()
      }
      Spacer()
    }
    .padding()
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
    }
  }
}

#Preview("CategoryTile") {
  CategoryTile(category: Category(id: 1, name: "Category 1", icon: "🍔"))
    .frame(width: 100, height: 100)
}
