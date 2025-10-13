//
//  AsyncImageView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-01.
//

import SwiftUI

struct AsyncImageView: View {
  let imagePath: String

  var body: some View {
    Color.clear
      .aspectRatio(1, contentMode: .fit)  // Square container
      .overlay(
        AsyncImage(url: URL(string: imagePath)) { phase in
          switch phase {
          case .empty:
            ProgressView()
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fill)  // Fill and crop
          case .failure:
            Image(systemName: "photo.circle.fill")
              .font(.largeTitle)
              .foregroundColor(.gray)
          @unknown default:
            EmptyView()
          }
        }
      )
      .clipped()
  }
}
