//
//  CardView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 18.06.2024.
//

import SwiftUI
import Kingfisher

struct CardView<Content: View, BackContent: View>: View {
    let content: () -> Content
    let backContent: () -> BackContent
    let width: CGFloat
    let height: CGFloat
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            if isFlipped {
                backContent()
            } else {
                content()
            }
        }
        .frame(width: width, height: height)
        .rotation3DEffect(
            Angle(degrees: isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.default, value: isFlipped)
    }
}

struct CardFrontContent: View {
    var word: WordModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
            Text(word.wordText)
                .font(.largeTitle)
                .padding()
        }
    }
}

struct CardBackContent: View {
    var word: WordModel
    private let imageFetcher = UnsplashImageFetcher()
    @State private var cardImageUrl: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
            VStack {
                Text(word.translation)
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

                VStack {
                    if let imageURL = cardImageUrl {
                        KFImage(URL(string: imageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        NotAvailablePhotoView()
                            .frame(height: 200)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .rotation3DEffect(Angle(degrees: -180), axis: (x: 0, y: 1, z: 0))
        .task {
            cardImageUrl = await imageFetcher.fetchImage(for: word.wordText)
        }
    }
}
