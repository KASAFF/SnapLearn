//
//  WordDetailView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 19.05.2024.
//

import SwiftUI

struct WordDetailView: View {
    let wordModel: WordModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Translation: \(wordModel.translation)")
                    .font(.headline)

            ScrollView {
                ForEach(wordModel.meanings) { meaning in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(meaning.partOfSpeech)
                            .font(.title2)
                            .bold()

                        ForEach(meaning.definitions) { definition in
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
                                if !definition.synonyms.isEmpty {
                                    Text("Synonyms: \(definition.synonyms.joined(separator: ", "))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .frame(alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle(wordModel.wordText)
    }
}
