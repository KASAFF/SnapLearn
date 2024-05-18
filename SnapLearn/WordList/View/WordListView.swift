//
//  WordListrView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct WordListView: View {
    @Environment(\.modelContext) var modelContext

    @State private var words = [WordModel]()
    @State private var showCardStack = false

    var body: some View {
        NavigationView {
            VStack {
                if showCardStack {
                    CardStackView(words: words)
                } else {
                    List(words) { word in
                        NavigationLink(destination: WordDetailView(word: word)) {
                            Text(word.word)
                        }
                    }
                    .onAppear {
                        fetchWords()
                    }
                }
            }
            .navigationTitle("My Words")
            .toolbar {
                Button {
                    showCardStack = true
                } label: {
                    Text("Start Learning")
                }
            }
        }
    }

    private func fetchWords() {
        do {
            words = try modelContext.fetch(.init())
        } catch {
            print(error)
        }
    }
}


struct WordDetailView: View {
    let word: WordModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(word.word)
                .font(.largeTitle)
                .bold()

            if let translation = word.translation {
                Text("Translation: \(translation)")
                    .font(.headline)
            }

            ScrollView {
                ForEach(word.meanings) { meaning in
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
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle(word.word)
    }
}

#Preview {
    WordListView()
}

