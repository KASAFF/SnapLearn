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
    @Published var newWordText = ""
    @Published var searchedWord = ""

    var wordModel: WordModel?

    @Published var wordEntity: WordEntity?
    @Published var translation: String?

    @Published var isShowingError = false
    @Published var selectedLanguage = "ru"
    @Published var languages = ["ru", "es", "fr", "de", "it", "zh"]
    @Published var isLoading = false

    func findDefinition() async -> WordEntity? {
        let baseURL = URLs.dictionaryapi
        self.searchedWord = newWordText
        guard let searchURL = URL(string: baseURL + searchedWord) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: searchURL)
            let wordEntries = try JSONDecoder().decode([WordEntity].self, from: data)
            return wordEntries.first
        } catch {
            isShowingError = true
            print("Failed to fetch or decode word entry: \(error)")
            return nil
        }
    }

    func translateText(targetLang: String) async -> String? {
        let encodedText = searchedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.lowercased() ?? ""
        let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=en|\(targetLang.lowercased())"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let translationResult = try JSONDecoder().decode(TranslationResult.self, from: data)
            guard translationResult.responseStatus == 200 else { return nil }
            return translationResult.responseData.translatedText.capitalized
        } catch {
            print("Failed to translate text: \(error)")
            return nil
        }
    }

    func fetchAndTranslate() {
        Task {
            isLoading = true
            async let wordEntryTask = findDefinition()
            async let translationTask = translateText(targetLang: selectedLanguage)

            // Await both tasks simultaneously and then set the properties
            let (wordEntry, translation) = await (wordEntryTask, translationTask)

            let model = convertToPresentationModel(wordEntry: wordEntry, translation: translation)
            self.translation = translation
            self.wordEntity = wordEntry
            self.wordModel = model
            isLoading = false
        }
    }

    func convertToPresentationModel(wordEntry: WordEntity?, translation: String?) -> WordModel {
        let meanings = wordEntry?.meanings.map { meaning in
            MeaningEntry(
                partOfSpeech: meaning.partOfSpeech,
                antonyms: meaning.antonyms,
                synonyms: meaning.synonyms,
                definitions: meaning.definitions.map { .init(entity: $0) }
            )
        } ?? []

        return WordModel(
            word: wordEntry?.word.capitalized ?? "",
            translation: translation,
            meanings: meanings
        )
    }

}

struct TranslationResult: Codable {
    let responseData: ResponseData
    let responseStatus: Int?
}

struct ResponseData: Codable {
    let translatedText: String
}
