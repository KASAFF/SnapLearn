//
//  CardBack.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 19.05.2024.
//

import SwiftUI
import Kingfisher

struct CardBack: View {
    var word: WordModel
    let width: CGFloat
    let height: CGFloat

    private let imageFetcher = UnsplashImageFetcher()

    @Binding var degree: Double
    @State private var imageLoaded: Bool = false
    @State private var loadFailed: Bool = false
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
                            .frame(height: height * 0.4)
                            .clipShape(.rect(cornerRadius: 12))
                    } else {
                        NotAvailablePhotoView()
                            .frame(height: height * 0.4)
                    }
                }

            }
            .padding(.horizontal, 16)
        }
        .frame(width: width, height: height)
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
        .task {
            cardImageUrl = await imageFetcher.fetchImage(for: word.wordText)
        }
    }
}
