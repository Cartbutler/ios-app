//
//  ShoppingResultsFilterView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import SwiftUI

struct ShoppingResultsFilterView: View {
  @StateObject private var viewModel: ShoppingResultsFilterViewModel
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL

  init(stores: [StoreFilterDTO], filterParameters: Binding<FilterParameters?>) {
    self._viewModel = StateObject(
      wrappedValue: ShoppingResultsFilterViewModel(
        stores: stores,
        filterParameters: filterParameters
      )
    )
  }

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(spacing: 16) {
          completeListSection
          distanceSection
          storesSection
        }
        .padding(.vertical)
      }
      
      // Sticky buttons section
      VStack(spacing: 12) {
        Divider()
        
        applyButton
        clearButton
      }
      .padding(.horizontal)
      .padding(.bottom)
      .background(Color.themeBackground)
    }
    .navigationTitle("Filter Results")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { closeButton }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .alert(
      "Location Permission Required", isPresented: $viewModel.showPermissionDeniedAlert,
      actions: {
        Button("Open Settings") {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
          }
        }
        Button("Dismiss") {
          viewModel.showPermissionDeniedAlert = false
        }
      },
      message: {
        Text("Please enable location access in Settings to filter by distance.")
      }
    )
    .alert(
      "Location Unavailable", isPresented: $viewModel.showLocationUnavailableAlert,
      actions: {
        Button("OK") {
          viewModel.showLocationUnavailableAlert = false
        }
      },
      message: {
        Text("Unable to get your current location. Please try again later.")
      })
  }

  private var completeListSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Availability")
        .font(.title3)
        .fontWeight(.semibold)
      
      Toggle(isOn: $viewModel.showCompleteOnly) {
        HStack(spacing: 8) {
          Image(systemName: "checkmark.seal.fill")
            .foregroundColor(.green)
          Text("Show only stores with all items")
            .font(.body)
        }
      }
      .tint(.themePrimary)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.themeSurface)
    )
    .padding(.horizontal)
  }

  private var distanceSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Distance")
        .font(.title3)
        .fontWeight(.semibold)

      HStack {
        distanceText(with: viewModel.minRadius)
        Slider(value: $viewModel.selectedRadius, in: viewModel.radiusRange, step: 1)
        distanceText(with: viewModel.maxRadius)
      }
      HStack {
        Spacer()
        distanceText(with: viewModel.selectedRadius)
        Spacer()
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.themeSurface)
    )
    .padding(.horizontal)
  }

  private func distanceText(with distance: Double) -> some View {
    Text("\(Int(distance))km")
      .font(.subheadline)
      .foregroundStyle(.secondaryVariant)
  }

  private var storesSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Stores")
        .font(.title3)
        .fontWeight(.semibold)

      ForEach(viewModel.stores) { store in
        storeCheckbox(for: store)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.themeSurface)
    )
    .padding(.horizontal)
  }

  private func storeCheckbox(for store: StoreFilterDTO) -> some View {
    HStack {
      Button {
        viewModel.toggleStoreSelection(store.id)
      } label: {
        Image(systemName: store.isSelected ? "checkmark.square.fill" : "square")
          .font(.title3)
          .foregroundStyle(.secondaryVariant)
      }

      AsyncImageView(imagePath: store.imagePath, style: .original)
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 8))

      Text(store.name)
        .font(.headline)

      Spacer()
    }
    .padding(.vertical, 4)
  }

  private var applyButton: some View {
    Button {
      Task {
        if await viewModel.applyFilters() {
          dismiss()
        }
      }
    } label: {
      Text("Apply Filters")
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    .foregroundStyle(.onPrimary)
    .buttonStyle(.borderedProminent)
  }

  private var clearButton: some View {
    Button {
      viewModel.clearFilters()
      dismiss()
    } label: {
      Text("Clear filters")
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    .foregroundStyle(.secondaryVariant)
    .buttonStyle(.bordered)
  }

  @ToolbarContentBuilder
  private var closeButton: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.title3)
      }
      .foregroundStyle(.onBackground)
    }
  }
}
