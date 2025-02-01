//
//  HomeView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-23.
//
import SwiftUI
import SwiftData

struct HomeView: View {
  @State private var searchText = ""
  
  @StateObject private var viewModel = HomeViewModel()
  
  @Query(sort: \Category.name)
  private var categories: [Category]
  
  var body: some View {
    NavigationStack {
      withAnimation {
        Group {
          if categories.isEmpty {
            butlerImage
          } else {
            categoriesGrid
          }
        }
      }
      .navigationTitle("CartButler")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.themePrimary, for: .navigationBar)
    }
    .searchable(text: $viewModel.searchKey, prompt: "Search products")
    .searchSuggestions {
      ForEach(viewModel.suggestions, id: \.self) { suggestion in
        NavigationLink {
          Text(suggestion)
        } label: {
          Text(suggestion)
        }
      }
    }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
  }
  
  private var categoriesGrid: some View {
    ScrollView {
      LazyVGrid(columns: [.init(.adaptive(minimum: 150))]) {
        ForEach(categories) { category in
          NavigationLink {
            CategoryTile(category: category)
          } label: {
            CategoryTile(category: category)
          }
        }
      }
      .padding()
    }
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
