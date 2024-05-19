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

    @Published var wordEntry: WordEntry?
    @Published var translation: String?

    @Published var isShowingError = false
    @Published var selectedLanguage = "ru"
    @Published var languages = ["ru", "es", "fr", "de", "it", "zh"]


    func findDefinition() async -> WordEntry? {
        let baseURL = URLs.dictionaryapi
        self.searchedWord = newWordText
        guard let searchURL = URL(string: baseURL + searchedWord) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: searchURL)
            let wordEntries = try JSONDecoder().decode([WordEntry].self, from: data)
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
            async let wordEntryTask = findDefinition()
            async let translationTask = translateText(targetLang: selectedLanguage)

            // Await both tasks simultaneously and then set the properties
            let (wordEntry, translation) = await (wordEntryTask, translationTask)

            let model = convertToPresentationModel(wordEntry: wordEntry, translation: translation)
            self.translation = translation
            self.wordEntry = wordEntry
            self.wordModel = model
        }
    }

    func convertToPresentationModel(wordEntry: WordEntry?, translation: String?) -> WordModel {
        let meanings = wordEntry?.meanings.map { meaning in
            MeaningPresentationModel(
                partOfSpeech: meaning.partOfSpeech,
                definitions: meaning.definitions.map { .init(entity: $0) }
            )
        } ?? []

        return WordModel(
            word: wordEntry?.word ?? "",
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