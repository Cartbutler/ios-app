//
//  StoreDetailsView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-03-16.
//

import MapKit
import SwiftUI

struct StoreDetailsView: View {
  let result: ShoppingResultsDTO
  @State private var storeMapItem: MKMapItem?

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        storeHeader
        productsList
        storeMapSection
      }
    }
    .navigationTitle(result.storeName)
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .task {
      await searchStoreLocation()
    }
  }

  private func searchStoreLocation() async {
    do {
      storeMapItem = try await StoreLocator.search(result)
    } catch {
      print("Error searching for location: \(error)")
    }
  }

  private var storeHeader: some View {
    VStack {
      AsyncImageView(imagePath: result.storeImage)
        .frame(width: 200)
        .padding(.bottom)
      Text(result.storeAddress)
        .font(.subheadline)
        .foregroundStyle(.secondaryVariant)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
      HStack(alignment: .bottom) {
        Text("\(result.products.count) items")
          .font(.subheadline)
          .foregroundStyle(.secondaryVariant)
        Spacer()
        Text(Formatter.currency(with: result.total))
          .font(.title)
          .fontWeight(.bold)
          .foregroundStyle(.primaryVariant)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.themeSurface)
    )
    .padding(.horizontal)
  }

  private var storeMapSection: some View {
    VStack(alignment: .leading) {
      Text("Location")
        .font(.title3)
        .fontWeight(.semibold)
        .padding(.horizontal)
      storeMap
    }
    .padding(.bottom)
  }

  private var productsList: some View {
    VStack(alignment: .leading) {
      Text("Products")
        .font(.title3)
        .fontWeight(.semibold)
        .padding(.horizontal)

      ForEach(result.products) { product in
        productRow(for: product)
          .padding(.horizontal)
          .padding(.vertical, 8)
      }
    }
  }

  private func productRow(for product: ShoppingResultsDTO.ProductDTO) -> some View {
    HStack {
      VStack(alignment: .leading) {
        Text(product.productName)
          .font(.headline)
        Text("Quantity: \(product.quantity)")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      Spacer()

      Text(Formatter.currency(with: product.total))
        .font(.title3)
        .fontWeight(.semibold)
    }
  }

  @ViewBuilder
  private var storeMap: some View {
    if let storeMapItem {
      let region = MKCoordinateRegion(
        center: storeMapItem.placemark.coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
      )
      Map(position: .constant(.region(region))) {
        Marker(item: storeMapItem)
      }
      .frame(height: 200)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .padding(.horizontal)
      .onTapGesture {
        StoreLocator.openMapsDirections(to: storeMapItem)
      }
    }
  }
}
