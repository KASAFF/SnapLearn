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

    let imageFetcher = UnsplashImageFetcher()

    @Binding var degree: Double
    @State private var imageLoaded: Bool = false
    @State private var loadFailed: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)

            VStack {
                if let translation = word.translation {
                    Text(translation)
                        .font(.largeTitle)
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

                if let imageURL = imageFetcher.imageURL {
                    KFImage(URL(string: imageURL))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                        .frame(height: height * 0.4)
                } else {
                    NotAvailablePhotoView()
                    .frame(height: height * 0.4)
                }

            }
            .padding(20)
        }
        .frame(width: width, height: height)
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
        .task {
            imageFetcher.fetchImage(for: word.word)
        }
    }
}
