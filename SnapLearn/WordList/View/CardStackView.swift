import SwiftUI

import SwiftUI

struct CardStackView: View {
    var words: [WordModel]
    var onLearnAgain: (WordModel) -> Void
    var onSuccessfullyLearned: (WordModel) -> Void
    var onEndLearning: () -> Void

    var body: some View {
        ZStack {
            ForEach(words) { card in
                CardView(word: card, onLearnAgain: onLearnAgain, onSuccessfullyLearned: onSuccessfullyLearned)
                    .onDisappear {
                        // Uncomment if you want to remove the card when it disappears
                        // removeCard(card)
                    }
                    .allowsHitTesting(card != words.first)
            }
        }
        .navigationTitle("Learning")
        .toolbar {
            Button {
                onEndLearning()
            } label: {
                Text("End Learning")
            }
        }
    }

    private func removeCard(_ card: WordModel) {
        // Implement the removal logic if needed
    }
}
