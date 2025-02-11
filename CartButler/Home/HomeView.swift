import SwiftData
//
//  HomeView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-23.
//
import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = HomeViewModel()
  @State private var searchKey = ""

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
      SuggestionsView(query: viewModel.query)
    }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .task {
      viewModel.fetchCategories()
    }
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

struct SuggestionsView: View {
  @Query
  private var suggestions: [Suggestion]

  init(query: String) {
    _suggestions = Query(
      filter: #Predicate { $0.suggestionSet.query == query },
      sort: [.init(\.priority)]
    )
  }

  var body: some View {
    ForEach(suggestions) { suggestion in
      NavigationLink {
        Text(suggestion.name)
      } label: {
        Text(suggestion.name)
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
