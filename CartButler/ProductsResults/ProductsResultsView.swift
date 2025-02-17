//
//  ProductsResultsView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-12.
//
import SwiftUI

struct ProductsResultsView: View {
  @StateObject private var viewModel: ProductsResultsViewModel

  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  init(searchType: SearchType) {
    _viewModel = StateObject(wrappedValue: ProductsResultsViewModel(searchType: searchType))
  }

  var body: some View {
    Group {
      if viewModel.isLoading {
        loadingView
      } else if let errorMessage = viewModel.errorMessage {
        errorView(message: errorMessage)
      } else if viewModel.products.isEmpty {
        emptyResultsView
      } else {
        productsGridView
      }
    }
    .task {
      await viewModel.fetchProducts()
    }
    .navigationTitle(viewModel.navigationTitle)
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
  }

  // MARK: - Private Views

  private var loadingView: some View {
    ProgressView("Loading products...")
  }

  private func errorView(message: String) -> some View {
    VStack {
      Image(systemName: "exclamationmark.triangle")
        .font(.largeTitle)
        .foregroundColor(.red)

      Text(message)
        .multilineTextAlignment(.center)
        .padding()

      Button("Retry") {
        Task {
          await viewModel.fetchProducts()
        }
      }
    }
    .padding()
  }

  private var emptyResultsView: some View {
    VStack {
      Image(systemName: "magnifyingglass")
        .font(.largeTitle)
        .foregroundColor(.gray)
      Text("No products found")
        .font(.headline)
        .padding(.top)
    }
  }

  private var productsGridView: some View {
    ScrollView {
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
        ForEach(viewModel.products) { product in
          ProductTile(product: product)
        }
      }
      .padding()
    }
  }
}
