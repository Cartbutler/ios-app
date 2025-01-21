//
//  MainView.swift
//  CartButler
//
//  Created by Cassiano Monteiro on 2025-01-20.
//

import SwiftUI

struct MainView: View {

  var body: some View {
    ZStack(alignment: .top) {
      Text("CartButler")
        .font(.largeTitle)
        .padding(.top, 100)
      butlerImage
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
                width: geometry.size.height / 3,
                height: geometry.size.height / 3
              )
              .aspectRatio(1, contentMode: .fit)
          }
          Spacer()
        }
        Spacer()
      }
    }
  }
}

#Preview {
  MainView()
}
