//
//  WordListrView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI
import SwiftData

struct WordListView: View {
    @Environment(\.modelContext) var modelContext

    @State private var words = [WordModel]() {
        didSet {
            print(words)
        }
    }
    @State private var showCardStack = false

    var body: some View {
        NavigationView {
            VStack {
                if showCardStack {
                    CardStackView(
                        words: words,
                        onLearnAgain: { word in
                            print("Learn Again: \(word.word)")
                            words.append(word)
                        },
                        onSuccessfullyLearned: { word in
                            print("Successfully Learned: \(word)")
                            words.removeAll { $0.id == word.id }
                        },
                        onEndLearning: {
                            showCardStack = false
                        }
                    )
                } else {
                    List {
                        ForEach(words) { word in
                            NavigationLink(destination: WordDetailView(wordModel: word)) {
                                Text(word.word)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteWord(word)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .onAppear {
                        fetchWords()
                    }
                }
            }
            .navigationTitle("My Words")
            .toolbar {
                if !showCardStack {
                    Button {
                        showCardStack = true
                    } label: {
                        Text("Start Learning")
                    }
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

    private func deleteWord(_ word: WordModel) {
        do {
            modelContext.delete(word)
            try modelContext.save()
            fetchWords()
        } catch {
            print(error)
        }
    }
}

#Preview {
    WordListView()
}

#Preview {
    WordListView()
}

