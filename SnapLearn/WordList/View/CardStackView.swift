import SwiftUI

struct CardStackView: View {
    @State private var words: [WordModel]
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
    let threshold: CGFloat = 40  // Threshold to start showing labels
    let maxOpacityThreshold: CGFloat = 100  // Max opacity threshold

    init(
        words: [WordModel],
        onLearnAgain: @escaping (WordModel) -> Void,
        onSuccessfullyLearned: @escaping (WordModel) -> Void,
        onEndLearning: @escaping () -> Void
    ) {
        _words = State(initialValue: words)
        self.onLearnAgain = onLearnAgain
        self.onSuccessfullyLearned = onSuccessfullyLearned
        self.onEndLearning = onEndLearning
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Needs Practice")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .cornerRadius(10)
                        .opacity(opacityForLabel(side: .left))
                        .padding(.leading, 20)

                    Spacer()

                    Text("Got It")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.green)
                        .cornerRadius(10)
                        .opacity(opacityForLabel(side: .right))
                        .padding(.trailing, 20)
                }
                .padding(.top, 20)

                Spacer()
            }

            VStack {
                Spacer()

                if words.isEmpty {
                    Text("No more words!")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                } else {
                    ZStack {
                        ForEach(words) { word in
                            if let index = words.firstIndex(where: { $0.id == word.id }), index == currentIndex {
                                ZStack {
                                    CardFront(word: word, width: width, height: height, degree: $frontDegree)
                                    CardBack(word: word, width: width, height: height, degree: $backDegree)
                                }
                                .frame(width: width, height: height)
                                .shadow(radius: 6)
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
                                            if abs(offset.width) > maxOpacityThreshold {
                                                if offset.width > 0 {
                                                    onSuccessfullyLearned(word)
                                                    removeCurrentWord()
                                                } else {
                                                    onLearnAgain(word)
                                                    moveCurrentWordToEnd()
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
                            }
                        }
                    }
                }

                Spacer()
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
        if currentIndex >= words.count {
            currentIndex = 0
        }
        backDegree = -90.0
        frontDegree = 0.0
        resetCardState()
    }

    func resetCardState() {
        isFlipped = false
        isSwiped = false
        offset = .zero
    }

    func removeCurrentWord() {
        words.remove(at: currentIndex)
        if currentIndex >= words.count {
            currentIndex = 0
        }
    }

    func moveCurrentWordToEnd() {
        let word = words.remove(at: currentIndex)
        words.append(word)
        if currentIndex >= words.count {
            currentIndex = 0
        }
    }

    private func opacityForLabel(side: SwipeSide) -> Double {
        let opacity: CGFloat
        if side == .left {
            opacity = min(max((-offset.width - threshold) / (maxOpacityThreshold - threshold), 0), 1)
        } else {
            opacity = min(max((offset.width - threshold) / (maxOpacityThreshold - threshold), 0), 1)
        }
        return Double(opacity)
    }

    enum SwipeSide {
        case left, right
    }
}
