//
//  DefinitionViewModel.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI
import SwiftData

enum SupportedLanguage: String, CaseIterable {
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

    var emoji: String {
        switch self {
        case .english:
            return "🇬🇧"
        case .russian:
            return "🇷🇺"
        case .spanish:
            return "🇪🇸"
        case .french:
            return "🇫🇷"
        case .german:
            return "🇩🇪"
        case .italian:
            return "🇮🇹"
        case .chinese:
            return "🇨🇳"
        }
    }

}

@MainActor
class DefinitionViewModel: ObservableObject {
    @Published var newWordText = ""
    @Published var searchedWord = ""

    var wordModel: WordModel?

    @Published var wordEntity: WordEntity?
    @Published var translation: String?
    @Published var newWordFetched = false

    @Published var isShowingError = false
    @Published var selectedLanguage: SupportedLanguage = .russian
    @Published var languages = SupportedLanguage.allCases
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
            isLoading = false
            print("Failed to fetch or decode word entry: \(error)")
            return nil
        }
    }

    struct TranslationResponse: Codable {
        struct Translation: Codable {
            let detectedSourceLanguage: String
            let text: String
        }

        let translations: [Translation]
    }

    func translateText(targetLang: SupportedLanguage) async -> String {
        let sourceText = searchedWord
        isLoading = true

        do {
            let translatedText = try await translateTextUsingDeepL(text: sourceText, targetLanguage: targetLang)
            return translatedText
        } catch {
            isShowingError = true
            isLoading = false
            print("Failed to translate text: \(error)")
        }

        isLoading = false
        return ""
    }

    func translateTextUsingDeepL(text: String, targetLanguage: SupportedLanguage) async throws -> String {
        guard let url = URL(string: "https://api-free.deepl.com/v2/translate") else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.lowercased()

        let apiKey = "4f376a62-1f3b-4ed3-921e-ac3693bcd921:fx"
        let parameters: [String: Any] = [
            "text": [encodedText],
            "target_lang": targetLanguage.rawValue
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("DeepL-Auth-Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Translation failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)"])
        }

        let decodedResponse = try decoder.decode(TranslationResponse.self, from: data)
        if let translatedText = decodedResponse.translations.first?.text {
            return translatedText.capitalized
        } else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Translation failed"])
        }
    }

    func fetchAndTranslate() async {
        Task {
            isLoading = true
            async let wordEntryTask = findDefinition()
            async let translationTask = translateText(targetLang: selectedLanguage)

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

    func convertToPresentationModel(wordEntity: WordEntity?, translation: String) -> WordModel {
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

//struct TranslationResult: Codable {
//    let matches: [Match]
//}
//
//struct Match: Codable {
//    let translation: String
//}
//
//struct ResponseData: Codable {
//    let translatedText: String
//}
