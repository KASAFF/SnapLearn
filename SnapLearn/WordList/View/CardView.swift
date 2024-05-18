import SwiftUI

struct CardView: View {
    var word: WordModel
    @State private var offset: CGSize = .zero
    @State private var isSwiped: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color.white)
                .shadow(radius: 10)

            VStack {
                Text(word.word)
                    .font(.largeTitle)
                    .padding()

                if let translation = word.translation {
                    Text(translation)
                        .font(.headline)
                        .padding(.bottom)
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
        }
        .frame(width: 300, height: 400)
        .offset(x: offset.width, y: offset.height * 0.2)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
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
}
