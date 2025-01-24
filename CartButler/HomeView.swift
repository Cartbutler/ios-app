//
//  HomeView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-23.
//
import SwiftUI

struct HomeView: View {
  @State private var searchText = ""
  
  var body: some View {
    NavigationStack {
      butlerImage
    }
    .searchable(text: $searchText, prompt: "Search products")
  }
  
  private var butlerImage: some View {
    GeometryReader { geometry in
      VStack(spacing: .zero) {
        Spacer()
        HStack {
          Spacer()
          VStack(alignment: .center, spacing: .zero) {
            Image(.butlerNoBackground)
              .resizable()
              .frame(
                width: geometry.size.height / 2,
                height: geometry.size.height / 2
              )
              .aspectRatio(1, contentMode: .fit)
              .opacity(0.2)
          }
          Spacer()
        }
        Spacer()
      }
    }
  }
}

#Preview("English") {
  HomeView()
}


#Preview("pt-BR") {
  HomeView()
    .environment(\.locale, .init(identifier: "pt-BR"))
}
