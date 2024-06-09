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

    @State private var words = [WordModel]()
    @State private var showCardStack = false

    var body: some View {
        NavigationView {
            VStack {
                if showCardStack {
                    CardStackView(
                        words: words.filter { !$0.isLearned },
                        onLearnAgain: { word in
                            print("Learn Again: \(word.word)")
                            word.isLearned = false
                            words.append(word)
                        },
                        onSuccessfullyLearned: { word in
                            print("Successfully Learned: \(word)")
                            word.isLearned = true
                            words.removeAll { $0.id == word.id }
                        },
                        onEndLearning: {
                            showCardStack = false
                        }
                    )
                } else {
                    List {
                        Section {
                            ForEach(words.filter { !$0.isLearned }) { word in
                                NavigationLink(destination: WordDetailView(wordModel: word)) {
                                    Text(word.word)
                                }
                                .swipeActions {
                                    Button {
                                        withAnimation(.none) {
                                            word.isLearned = true
                                        }
                                    } label: {
                                        Label("Mark as Learned", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                    Button(role: .destructive) {
                                        deleteWord(word)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        } header: {
                            Text("To learn")
                        }
                        Section {
                            ForEach(words.filter { $0.isLearned }) { word in
                                NavigationLink(destination: WordDetailView(wordModel: word)) {
                                    Text(word.word)
                                }
                                .swipeActions {
                                    Button("Still learning") {
                                        withAnimation(.none) {
                                            word.isLearned = false
                                        }
                                    }
                                    .tint(.orange)
                                    Button(role: .destructive) {
                                        deleteWord(word)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        } header: {
                            Text("Learned already")
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
