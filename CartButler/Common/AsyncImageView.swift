//
//  AsyncImageView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-01.
//

import SwiftUI

enum AsyncImageStyle {
  case square
  case original
  case aspectRatio(CGFloat)
}

struct AsyncImageView: View {
  let imagePath: String
  var style: AsyncImageStyle = .square

  var body: some View {
    switch style {
    case .original: imageContent(fillMode: .fit)
    case .square: framed(aspectRatio: 1)
    case .aspectRatio(let ratio): framed(aspectRatio: ratio)
    }
  }

  @ViewBuilder
  private func framed(aspectRatio: CGFloat) -> some View {
    Color.clear
      .aspectRatio(aspectRatio, contentMode: .fit)
      .overlay(imageContent(fillMode: .fill))
      .clipped()
  }

  @ViewBuilder
  private func imageContent(fillMode: ContentMode) -> some View {
    AsyncImage(url: URL(string: imagePath)) { phase in
      switch phase {
      case .empty:
        ProgressView()
      case .success(let image):
        image
          .resizable()
          .aspectRatio(contentMode: fillMode)
      case .failure:
        Image(systemName: "photo.circle.fill")
          .font(.largeTitle)
      @unknown default:
        EmptyView()
      }
    }
  }
}
