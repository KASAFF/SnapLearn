import SwiftUI

struct CardStackView: View {

    // MARK: - Constants

    enum Constants {
        static let cardWidth: CGFloat = 320
        static let cardHeight: CGFloat = 440
        static let animationDuration: CGFloat = 0.15
        static let swipeThreshold: CGFloat = 40
        static let maxOpacityThreshold: CGFloat = 100
    }

    // MARK: - State Properties

    @State private var words: [WordModel]
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var offset: CGSize = .zero
    @State private var isSwiped: Bool = false
    @State private var backDegree = -90.0
    @State private var frontDegree = 0.0

    // MARK: - Internal Properties

    var onLearnAgain: (WordModel) -> Void
    var onSuccessfullyLearned: (WordModel) -> Void
    var onEndLearning: () -> Void

    // MARK: - Initializer

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

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack {
                headerView
                Spacer()
            }

            VStack {
                Spacer()
                if words.isEmpty {
                    emptyWordsView
                } else {
                    cardsView
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

    // MARK: - Subviews

    private var headerView: some View {
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
    }

    private var emptyWordsView: some View {
        Text("No more words!")
            .font(.largeTitle)
            .foregroundColor(.gray)
    }

    private var cardsView: some View {
        ZStack {
            ForEach(words) { word in
                if let index = words.firstIndex(where: { $0.id == word.id }), index == currentIndex {
                    CardView(
                        content: {
                            CardFrontContent(word: word)
                        },
                        backContent: {
                            CardBackContent(word: word)
                        },
                        width: Constants.cardWidth,
                        height: Constants.cardHeight,
                        isFlipped: $isFlipped
                    )
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
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
                                handleDragEnd()
                            }
                    )
                    .opacity(isSwiped ? 0 : 1)
                }
            }
        }
    }

    // MARK: - Enums

    enum SwipeSide {
        case left, right
    }
}

// MARK: - Private Methods

private extension CardStackView {

    func flipCard() {
        isFlipped.toggle()
        if isFlipped {
            withAnimation(.linear(duration: Constants.animationDuration).delay(Constants.animationDuration)) {
                backDegree = 0
            }
            withAnimation(.linear(duration: Constants.animationDuration)) {
                frontDegree = 90
            }
        } else {
            withAnimation(.linear(duration: Constants.animationDuration).delay(Constants.animationDuration)) {
                frontDegree = 0
            }
            withAnimation(.linear(duration: Constants.animationDuration)) {
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

    func opacityForLabel(side: SwipeSide) -> Double {
        let opacity: CGFloat
        if side == .left {
            opacity = min(max((-offset.width - Constants.swipeThreshold) / (Constants.maxOpacityThreshold - Constants.swipeThreshold), 0), 1)
        } else {
            opacity = min(max((offset.width - Constants.swipeThreshold) / (Constants.maxOpacityThreshold - Constants.swipeThreshold), 0), 1)
        }
        return Double(opacity)
    }

    func handleDragEnd() {
        if abs(offset.width) > Constants.maxOpacityThreshold {
            if offset.width > 0 {
                onSuccessfullyLearned(words[currentIndex])
                removeCurrentWord()
            } else {
                onLearnAgain(words[currentIndex])
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
}
