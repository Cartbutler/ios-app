//
//  ShoppingResultsFilterView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import SwiftUI

struct ShoppingResultsFilterView: View {
  let results: [ShoppingResultsDTO]
  @State private var selectedRadius = 10.0
  @State private var selectedStores: Set<Int> = []
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        distanceSection
        storesSection
        Spacer()
        applyButton
      }
      .padding(.vertical)
    }
    .navigationTitle("Filter Results")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { closeButton }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
  }

  private var distanceSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Distance")
        .font(.title3)
        .fontWeight(.semibold)

      HStack {
        Text("1km")
          .font(.subheadline)
          .foregroundStyle(.secondaryVariant)
        Slider(value: $selectedRadius, in: 1...10, step: 1)
        Text("10km")
          .font(.subheadline)
          .foregroundStyle(.secondaryVariant)
      }
      HStack {
        Spacer()
        Text("\(Int(selectedRadius))km")
          .font(.subheadline)
          .foregroundStyle(.secondaryVariant)
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

  private var storesSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Stores")
        .font(.title3)
        .fontWeight(.semibold)
      ForEach(results) { result in
        storeCheckbox(for: result)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.themeSurface)
    )
    .padding(.horizontal)
  }

  private func storeCheckbox(for result: ShoppingResultsDTO) -> some View {
    HStack {
      Button {
        if selectedStores.contains(result.storeId) {
          selectedStores.remove(result.storeId)
        } else {
          selectedStores.insert(result.storeId)
        }
      } label: {
        Image(
          systemName: selectedStores.contains(result.storeId) ? "checkmark.square.fill" : "square"
        )
        .font(.title3)
        .foregroundStyle(.secondaryVariant)
      }

      AsyncImageView(imagePath: result.storeImage)
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 8))

      Text(result.storeName)
        .font(.headline)

      Spacer()
    }
    .padding(.vertical, 4)
  }

  private var applyButton: some View {
    Button {
      // TODO: Apply filters
      dismiss()
    } label: {
      Text("Apply Filters")
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    .foregroundStyle(.onPrimary)
    .buttonStyle(.borderedProminent)
    .padding(.horizontal)
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
