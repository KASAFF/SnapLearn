//
//  WordListView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI
import SwiftData

struct WordListView: View {
    @Environment(\.modelContext) var modelContext

    // MARK: - State Properties

    @State private var words = [WordModel]()
    @State private var showCardStack = false

    // MARK: - Constants

    enum Constants {
        static let toLearnSectionHeader = "To learn"
        static let learnedSectionHeader = "Learned already"
        static let startLearningButton = "Start Learning"
        static let navigationTitle = "My Words"
        static let markAsLearned = "Mark as Learned"
        static let delete = "Delete"
        static let stillLearning = "Still learning"
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack {
                if showCardStack {
                    cardStackView
                } else {
                    wordListView
                        .onAppear {
                            fetchWords()
                        }
                }
            }
            .navigationTitle(Constants.navigationTitle)
            .toolbar {
                if !showCardStack {
                    Button {
                        showCardStack = true
                    } label: {
                        Text(Constants.startLearningButton)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var cardStackView: some View {
        CardStackView(
            words: words.filter { !$0.isLearned },
            onLearnAgain: { word in
                word.isLearned = false
                words.append(word)
            },
            onSuccessfullyLearned: { word in
                word.isLearned = true
                words.removeAll { $0.id == word.id }
            },
            onEndLearning: {
                showCardStack = false
            }
        )
    }

    private var wordListView: some View {
        List {
            Section {
                ForEach(words.filter { !$0.isLearned }) { word in
                    NavigationLink(destination: WordDetailView(wordModel: word)) {
                        Text(word.wordText)
                    }
                    .swipeActions {
                        markAsLearnedButton(for: word)
                        deleteButton(for: word)
                    }
                }
            } header: {
                Text(Constants.toLearnSectionHeader)
            }
            Section {
                ForEach(words.filter { $0.isLearned }) { word in
                    NavigationLink(destination: WordDetailView(wordModel: word)) {
                        Text(word.wordText)
                    }
                    .swipeActions {
                        stillLearningButton(for: word)
                        deleteButton(for: word)
                    }
                }
            } header: {
                Text(Constants.learnedSectionHeader)
            }
        }
    }

}

// MARK: - Private Methods

private extension WordListView {

    func fetchWords() {
        do {
            words = try modelContext.fetch(.init())
        } catch {
            print(error)
        }
    }

    func deleteWord(_ word: WordModel) {
        do {
            modelContext.delete(word)
            try modelContext.save()
            fetchWords()
        } catch {
            print(error)
        }
    }

    func markAsLearnedButton(for word: WordModel) -> some View {
        Button {
            withAnimation(.none) {
                word.isLearned = true
            }
        } label: {
            Label(Constants.markAsLearned, systemImage: "checkmark")
        }
        .tint(.green)
    }

    func stillLearningButton(for word: WordModel) -> some View {
        Button(Constants.stillLearning) {
            withAnimation(.none) {
                word.isLearned = false
            }
        }
        .tint(.orange)
    }

    func deleteButton(for word: WordModel) -> some View {
        Button(role: .destructive) {
            deleteWord(word)
        } label: {
            Label(Constants.delete, systemImage: "trash")
        }
    }

}
