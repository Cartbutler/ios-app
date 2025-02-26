//
//  ErrorView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-02-22.
//

import SwiftUI

struct ErrorView: View {
  let message: String
  let retryAction: () async -> Void

  var body: some View {
    VStack {
      Image(systemName: "exclamationmark.triangle")
        .font(.largeTitle)
        .foregroundColor(.error)

      Text(message)
        .multilineTextAlignment(.center)
        .padding()

      Button("Retry") {
        Task { await retryAction() }
      }
      .buttonStyle(.borderedProminent)
      .foregroundStyle(.onPrimary)
    }
    .foregroundStyle(.onBackground)
    .backgroundStyle(.themeBackground)
    .padding()
  }
}
