//
//  ShoppingResultsView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-08.
//

import SwiftUI

struct ShoppingResultsView: View {
  @EnvironmentObject private var coordinator: TabCoordinator
  @StateObject private var viewModel = ShoppingResultsViewModel()
  @State private var isFilterSheetPresented = false

  var body: some View {
    Group {
      switch viewModel.state {
      case .idle, .loading:
        loadingView
      case .error(let errorMessage):
        errorView(message: errorMessage)
          .alert(errorMessage, isPresented: $viewModel.showAlert) {
            Button("OK") {
              viewModel.showAlert = false
            }
          }
      case .loaded(let cheapest):
        VStack(spacing: 16) {
          bestDealSection(cheapest)
          otherResultsList
          Spacer()
        }
      case .empty:
        emptyResultsView
      }
    }
    .navigationTitle("Shopping Results")
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .toolbar { filterButton }
    .sheet(isPresented: $isFilterSheetPresented) {
      NavigationStack {
        ShoppingResultsFilterView(
          stores: viewModel.availableStores,
          filterParameters: $viewModel.filterParameters
        )
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

  private func errorView(message: LocalizedStringKey) -> some View {
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
      if viewModel.hasFilters {
        clearFiltersButton
      }
    }
  }

  private var clearFiltersButton: some View {
    Button {
      viewModel.filterParameters = nil
    } label: {
      Text("Clear filters")
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    .foregroundStyle(.onPrimary)
    .buttonStyle(.borderedProminent)
    .padding(.horizontal)
  }

  @ToolbarContentBuilder
  private var filterButton: some ToolbarContent {
    if viewModel.isFilterAvailable {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          isFilterSheetPresented = true
        } label: {
          Image(systemName: "line.3.horizontal.decrease")
            .font(.title2)
            .overlay(alignment: .topTrailing) { filterBadge }
        }
        .foregroundStyle(.onBackground)
      }
    }
  }

  @ViewBuilder
  private var filterBadge: some View {
    if viewModel.filterParameters != nil {
      Circle()
        .fill(Color.themePrimary)
        .frame(width: 8, height: 8)
        .offset(x: 4, y: -4)
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

  @ViewBuilder
  private var otherResultsList: some View {
    if !viewModel.otherResults.isEmpty {
      VStack(alignment: .leading) {
        Text("Other Options")
          .font(.title3)
          .fontWeight(.semibold)
          .padding(.horizontal)

        List {
          ForEach(viewModel.otherResults) { result in
            storeRow(result: result)
          }
        }
        .listStyle(.plain)
      }
    }
  }

  private func storeRow(result: ShoppingResultsDTO, style: StoreRowStyle = .others) -> some View {
    Button {
      coordinator.navigate(to: result)
    } label: {
      storeCard(result: result, style: style)
    }
    .buttonStyle(.plain)
  }

  private func storeCard(result: ShoppingResultsDTO, style: StoreRowStyle = .others) -> some View {
    HStack {
      storeImage(result: result, style: style)
      storeInfo(result: result, style: style)
      Spacer()
      priceInfo(result: result, style: style)
    }
  }

  private func storeImage(result: ShoppingResultsDTO, style: StoreRowStyle) -> some View {
    AsyncImageView(imagePath: result.storeImage, style: .original)
      .frame(width: style.imageSize, height: style.imageSize)
  }

  private func storeInfo(result: ShoppingResultsDTO, style: StoreRowStyle) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(result.storeName)
        .font(style.nameFont)
        .fontWeight(.bold)
      
      locationInfo(result: result, style: style)
      
      if !result.isComplete {
        missingItemsIndicator(result: result)
      }
    }
  }

  private func locationInfo(result: ShoppingResultsDTO, style: StoreRowStyle) -> some View {
    HStack(spacing: 4) {
      Text(result.storeLocation)
      if let distance = result.distance {
        Text("•")
        Text(Formatter.distance(kilometers: distance))
      }
    }
    .font(style.locationFont)
    .foregroundColor(.secondary)
  }

  private func priceInfo(result: ShoppingResultsDTO, style: StoreRowStyle) -> some View {
    VStack(alignment: .trailing, spacing: 4) {
      Text(Formatter.currency(with: result.total))
        .font(style.priceFont)
        .fontWeight(.bold)
      
      itemsStatusIndicator(result: result, style: style)
    }
  }

  private func itemsStatusIndicator(result: ShoppingResultsDTO, style: StoreRowStyle) -> some View {
    Group {
      if result.isComplete {
        completeListBadge
      } else {
        incompleteItemsLabel(count: result.products.count, style: style)
      }
    }
  }

  private func incompleteItemsLabel(count: Int, style: StoreRowStyle) -> some View {
    HStack(spacing: 2) {
      Image(systemName: "exclamationmark.circle")
        .font(.caption)
        .foregroundColor(.orange)
      Text("\(count) items")
        .font(style.itemsFont)
        .foregroundColor(.secondary)
    }
  }

  private var completeListBadge: some View {
    HStack(spacing: 2) {
      Image(systemName: "checkmark.seal.fill")
        .font(.caption)
      Text("All items")
        .font(.caption)
        .fontWeight(.semibold)
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background(
      Capsule()
        .fill(Color.green.opacity(0.15))
    )
    .foregroundColor(.green)
  }

  private func missingItemsIndicator(result: ShoppingResultsDTO) -> some View {
    Text("Some items unavailable")
      .font(.caption)
      .foregroundColor(.orange)
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
