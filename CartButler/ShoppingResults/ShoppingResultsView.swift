//
//  ShoppingResultsView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import SwiftUI

struct ShoppingResultsView: View {
  @StateObject private var viewModel = ShoppingResultsViewModel()

  var body: some View {
    Group {
      if viewModel.isLoading {
        loadingView
      } else if let errorMessage = viewModel.errorMessage {
        errorView(message: errorMessage)
      } else if let results = viewModel.results, !results.isEmpty {
        resultsList(with: results)
      } else {
        emptyResultsView
      }
    }
    .navigationTitle("Shopping Results")
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .alert(viewModel.errorMessage ?? "", isPresented: $viewModel.showAlert) {
      Button("OK") {
        viewModel.errorMessage = nil
      }
    }
    .task {
      await viewModel.fetchResults()
    }
  }

  // MARK: - Private Views

  private var loadingView: some View {
    ProgressView("Loading results...")
  }

  private func errorView(message: String) -> some View {
    ErrorView(message: message) {
      await viewModel.fetchResults()
    }
  }

  private var emptyResultsView: some View {
    VStack {
      Image(systemName: "cart.badge.questionmark")
        .font(.largeTitle)
      Text("No shopping results found")
        .font(.headline)
        .padding(.top)
    }
  }

  private func resultsList(with results: [ShoppingResultsDTO]) -> some View {
    List {
      ForEach(results) { result in
        storeRow(result: result)
      }
    }
    .listStyle(.plain)
  }

  private func storeRow(result: ShoppingResultsDTO) -> some View {
    HStack {
      Image(systemName: "photo.circle.fill")
        .font(.largeTitle)
        .frame(width: 60, height: 60)
      VStack(alignment: .leading) {
        Text(result.storeName)
          .font(.headline)
        Text(result.storeLocation)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
      Spacer()
      VStack(alignment: .trailing) {
        Text(Formatter.currency(from: result.total))
          .font(.title3)
          .fontWeight(.bold)
        Text("\(result.products.count) items")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
    }
  }
}
