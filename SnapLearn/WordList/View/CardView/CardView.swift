import SwiftUI

struct CardView: View {
    var word: WordModel
    @State private var offset: CGSize = .zero
    @State private var isSwiped: Bool = false
    @State private var isFlipped: Bool = false

    var onLearnAgain: (WordModel) -> Void
    var onSuccessfullyLearned: (WordModel) -> Void

    var body: some View {
        ZStack {
            if isFlipped {
                backSide
                    .background {
                        Color.red
                    }
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                frontSide
                    .background {
                        Color.green
                    }
            }
        }
        .frame(width: 300, height: 400)
        .background(RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(Color.white)
            .shadow(radius: 6))
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .gesture(
            TapGesture()
                .onEnded {
                    withAnimation {
                        isFlipped.toggle()
                    }
                }
        )
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
                            onSuccessfullyLearned(word)
                        } else {
                            onLearnAgain(word)
                        }
                        isSwiped = true
                    } else {
                        offset = .zero
                    }
                }
        )
        .animation(.spring(), value: offset)
        .opacity(isSwiped ? 0 : 1)
        .scaleEffect(isSwiped ? 0.5 : 1)
    }

    var frontSide: some View {
        VStack {
            Text(word.word)
                .font(.largeTitle)
                .padding()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(25)
    }

    var backSide: some View {
        VStack {
            if let translation = word.translation {
                Text(translation)
                    .font(.largeTitle)
                    .padding()
            }

            if let meaning = word.meanings.first {
                Text(meaning.partOfSpeech)
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 2)

                if let definition = meaning.definitions.first {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(definition.definition)
                            .font(.body)
                            .lineLimit(3)
                        if let example = definition.example {
                            Text("Example: \(example)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        if let synonym = definition.synonyms.first {
                            Text("Synonym: \(synonym)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(25)
    }
}