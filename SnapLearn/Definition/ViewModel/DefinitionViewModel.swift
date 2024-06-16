//
//  DefinitionViewModel.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI
import SwiftData

enum SupportedLanguages: String, CaseIterable {
    case english = "en"
    case russian = "ru"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case chinese = "zh"

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .russian:
            return "Russian"
        case .spanish:
            return "Spanish"
        case .french:
            return "French"
        case .german:
            return "German"
        case .italian:
            return "Italian"
        case .chinese:
            return "Chinese"
        }
    }
}

@MainActor
class DefinitionViewModel: ObservableObject {
    @Published var newWordText = ""
    @Published var searchedWord = ""

    var wordModel: WordModel?

    @Published var wordEntity: WordEntity?
    @Published var translation: [String]?
    @Published var newWordFetched = false

    @Published var isShowingError = false
    @Published var selectedLanguage: SupportedLanguages = .russian
    @Published var languages = SupportedLanguages.allCases
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

    func translateText(originalLang: SupportedLanguages, targetLang: SupportedLanguages) async -> [String] {
        let encodedText = searchedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.lowercased() ?? ""
        let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=\(originalLang.rawValue)|\(targetLang.rawValue)"
        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let translationResult = try JSONDecoder().decode(TranslationResult.self, from: data)
            let matches = translationResult.matches
            let translations = matches.prefix(2).map { $0.translation.capitalized }
            return translations
        } catch {
            print("Failed to translate text: \(error)")
            return []
        }
    }

    func fetchAndTranslate() async {
        Task {
            isLoading = true
            async let wordEntryTask = findDefinition()
            async let translationTask = translateText(originalLang: .english, targetLang: selectedLanguage)

            // Await both tasks simultaneously and then set the properties
            let (wordEntry, translation) = await (wordEntryTask, translationTask)

            let model = convertToPresentationModel(wordEntity: wordEntry, translation: translation)
            self.translation = translation
            self.wordEntity = wordEntry
            self.wordModel = model
            isLoading = false
            newWordFetched = true
        }
    }

    func convertToPresentationModel(wordEntity: WordEntity?, translation: [String]) -> WordModel {
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

struct TranslationResult: Codable {
    let matches: [Match]
}

struct Match: Codable {
    let translation: String
}

struct ResponseData: Codable {
    let translatedText: String
}
