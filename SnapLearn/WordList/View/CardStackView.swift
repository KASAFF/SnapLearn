import SwiftUI

struct CardStackView: View {
    var words: [WordModel]
    var onLearnAgain: (WordModel) -> Void
    var onSuccessfullyLearned: (WordModel) -> Void
    var onEndLearning: () -> Void

    @State private var currentIndex = 0
    @State var backDegree = -90.0
    @State var frontDegree = 0.0
    @State private var isFlipped = false
    @State private var offset: CGSize = .zero
    @State private var isSwiped: Bool = false
    let width: CGFloat = 320
    let height: CGFloat = 440
    let durationAndDelay: CGFloat = 0.15

    var body: some View {
        ZStack {
            if currentIndex < words.count {
                // Next card below the current card
                if currentIndex + 1 < words.count {
                    ZStack {
                        CardFront(word: words[currentIndex + 1], width: width, height: height, degree: .constant(0))
                    }
                    .frame(width: width, height: height)
                    .background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).shadow(radius: 6))
                    .opacity(0.5)
                    .offset(y: 10)
                }

                // Current card
                ZStack {
                    CardFront(word: words[currentIndex], width: width, height: height, degree: $frontDegree)
                    CardBack(word: words[currentIndex], width: width, height: height, degree: $backDegree)
                }
                .frame(width: width, height: height)
                .background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white).shadow(radius: 6))
                .onTapGesture {
                    flipCard()
                }
                .offset(x: offset.width, y: offset.height * 0.2)
                .rotationEffect(.degrees(Double(offset.width / 40)))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { _ in
                            if abs(offset.width) > 100 {
                                if offset.width > 0 {
                                    onSuccessfullyLearned(words[currentIndex])
                                } else {
                                    onLearnAgain(words[currentIndex])
                                }
                                isSwiped = true
                                withAnimation(.easeOut(duration: 0.3)) {
                                    offset = CGSize(width: offset.width * 5, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    loadNextCard()
                                }
                            } else {
                                withAnimation {
                                    offset = .zero
                                }
                            }
                        }
                )
                .opacity(isSwiped ? 0 : 1)
            } else {
                Text("No more words!")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
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

    func flipCard() {
        isFlipped.toggle()
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                backDegree = 0
            }
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = 90
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                frontDegree = 0
            }
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = -90
            }
        }
    }

    func loadNextCard() {
        currentIndex += 1
        backDegree = -90.0
        frontDegree = 0.0
        resetCardState()
    }

    func resetCardState() {
        isFlipped = false
        isSwiped = false
        offset = .zero
    }
}

#Preview {
    CardStackView(
        words: [
            WordModel(word: "Example", translation: "Ejemplo", meanings: [
                MeaningPresentationModel(partOfSpeech: "Noun", definitions: [
                    Definition(definition: "A representative form or pattern", synonyms: ["instance"], antonyms: [], example: "This is an example sentence.")
                ])
            ]),
            WordModel(word: "Test", translation: "Prueba", meanings: [
                MeaningPresentationModel(partOfSpeech: "Verb", definitions: [
                    Definition(definition: "A procedure intended to establish the quality, performance, or reliability of something.", synonyms: ["trial"], antonyms: [], example: "This is a test sentence.")
                ])
            ])
        ],
        onLearnAgain: { word in print("Learn Again: \(word.word)") },
        onSuccessfullyLearned: { word in print("Successfully Learned: \(word.word)") },
        onEndLearning: { print("End Learning") }
    )
}
