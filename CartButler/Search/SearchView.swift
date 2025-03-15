//
//  SearchView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-23.
//
import SwiftData
import SwiftUI

struct SearchView: View {
  @StateObject private var viewModel = SearchViewModel()
  @State private var presentSearchResults = false

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
      .navigationDestination(isPresented: $presentSearchResults) {
        ProductsResultsView(searchType: .query(viewModel.query))
      }
      .navigationTitle("CartButler")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.themePrimary, for: .navigationBar)
    }
    .searchable(text: $viewModel.searchKey, prompt: "Search products")
    .onSubmit(of: .search) {
      presentSearchResults = true
    }
    .searchSuggestions {
      SuggestionsView(searchKey: $viewModel.searchKey, query: viewModel.query)
    }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .task {
      viewModel.fetchCategories()
    }
  }

  private var categoriesGrid: some View {
    ScrollView {
      LazyVGrid(columns: [.init(.adaptive(minimum: 150))], spacing: 8) {
        ForEach(categories) { category in
          NavigationLink {
            ProductsResultsView(searchType: .category(category))
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
  @Binding private var searchKey: String
  @Query private var suggestions: [Suggestion]

  init(searchKey: Binding<String>, query: String) {
    self._searchKey = searchKey
    _suggestions = Query(
      filter: #Predicate { $0.suggestionSet.query == query },
      sort: [.init(\.priority)]
    )
  }

  var body: some View {
    ForEach(suggestions) { suggestion in
      Button {
        searchKey = suggestion.name
      } label: {
        Text(suggestion.name)
      }
    }
  }
}

#Preview("English") {
  SearchView()
}

#Preview("pt-BR") {
  SearchView()
    .environment(\.locale, .init(identifier: "pt-BR"))
}
