//
//  DefinitionViewModel.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI
import SwiftData

@MainActor
class DefinitionViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var newWordText = ""
    @Published var searchedWord = ""
    @Published var wordEntity: WordEntity?
    @Published var translation: String?
    @Published var newWordFetched = false
    @Published var isShowingError = false
    @Published var selectedLanguage: SupportedLanguage = .russian
    @Published var languages = SupportedLanguage.allCases
    @Published var isLoading = false

    // MARK: - Private Properties

    var wordModel: WordModel?

    // MARK: - Services

    private let translationService = TranslationService()

    // MARK: - Public Methods

    func fetchAndTranslate() async {
        isLoading = true
        async let wordEntryTask = translationService.findDefinition(for: newWordText)
        async let translationTask = translationService.translateText(searchedWord: newWordText, targetLanguage: selectedLanguage)

        let (wordEntry, translation) = await (wordEntryTask, translationTask)

        if let wordEntry = wordEntry {
            self.wordEntity = wordEntry
            self.translation = translation
            self.wordModel = convertToPresentationModel(wordEntity: wordEntry, translation: translation)
            self.newWordFetched = true
        } else {
            self.isShowingError = true
        }

        isLoading = false
    }

    // MARK: - Private Methods

    private func convertToPresentationModel(wordEntity: WordEntity?, translation: String) -> WordModel {
        let meanings = wordEntity?.meanings.map { meaning in
            MeaningEntry(
                partOfSpeech: meaning.partOfSpeech,
                antonyms: meaning.antonyms,
                synonyms: meaning.synonyms,
                definitions: meaning.definitions.map { .init(entity: $0) }
            )
        } ?? []

        return WordModel(
            word: wordEntity?.word.capitalized ?? "",
            translation: translation,
            meanings: meanings
        )
    }

}
