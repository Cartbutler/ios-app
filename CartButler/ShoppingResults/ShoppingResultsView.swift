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
      } else if let cheapest = viewModel.cheapestResult {
        VStack(spacing: 16) {
          bestDealSection(cheapest)
          if let others = viewModel.otherResults, !others.isEmpty {
            otherResultsList(with: others)
          }
        }
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

  private func bestDealSection(_ result: ShoppingResultsDTO) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Best Deal")
        .font(.title)
        .fontWeight(.bold)
        .padding(.horizontal)

      storeRow(result: result, style: .bestDeal)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.themeSurface)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .strokeBorder(Color.themePrimary, lineWidth: 2)
        )
        .padding(.horizontal)
    }
  }

  private func otherResultsList(with results: [ShoppingResultsDTO]) -> some View {
    VStack(alignment: .leading) {
      Text("Other Options")
        .font(.title3)
        .fontWeight(.semibold)
        .padding(.horizontal)

      List {
        ForEach(results) { result in
          storeRow(result: result)
        }
      }
      .listStyle(.plain)
    }
  }

  private func storeRow(result: ShoppingResultsDTO, style: StoreRowStyle = .others) -> some View {
    NavigationLink(destination: StoreDetailsView(result: result)) {
      storeCard(result: result, style: style)
    }
    .buttonStyle(.plain)
  }

  private func storeCard(result: ShoppingResultsDTO, style: StoreRowStyle = .others) -> some View {
    HStack {
      AsyncImageView(imagePath: result.storeImage)
        .frame(width: style.imageSize, height: style.imageSize)
      VStack(alignment: .leading) {
        Text(result.storeName)
          .font(style.nameFont)
          .fontWeight(.bold)
        Text(result.storeLocation)
          .font(style.locationFont)
          .foregroundColor(.secondary)
      }
      Spacer()
      VStack(alignment: .trailing) {
        Text(Formatter.currency(with: result.total))
          .font(style.priceFont)
          .fontWeight(.bold)
        Text("\(result.products.count) items")
          .font(style.itemsFont)
          .foregroundColor(.secondary)
      }
    }
  }

  private enum StoreRowStyle {
    case bestDeal
    case others

    var imageSize: CGFloat {
      switch self {
      case .bestDeal: 60
      case .others: 40
      }
    }

    var nameFont: Font {
      switch self {
      case .bestDeal: .largeTitle
      case .others: .headline
      }
    }

    var locationFont: Font {
      switch self {
      case .bestDeal: .subheadline
      case .others: .subheadline
      }
    }

    var priceFont: Font {
      switch self {
      case .bestDeal: .title
      case .others: .title3
      }
    }

    var itemsFont: Font {
      switch self {
      case .bestDeal: .subheadline
      case .others: .subheadline
      }
    }
  }
}
