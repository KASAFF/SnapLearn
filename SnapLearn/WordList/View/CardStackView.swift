//
//  CardStackView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 19.05.2024.
//

import SwiftUI

struct CardStackView: View {
    var words: [WordModel]

    var body: some View {
        ZStack {
            ForEach(words) { card in
                CardView(word: card)
                    .onDisappear {
                        // Uncomment if you want to remove the card when it disappears
                        // removeCard(card)
                    }
            }
        }
        .navigationTitle("Learning")
        .toolbar {
            Button {
                // Add your functionality here if needed
            } label: {
                Text("End Learning")
            }
        }
    }

    private func removeCard(_ card: WordModel) {
        // Implement the removal logic if needed
    }
}
