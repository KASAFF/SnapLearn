//
//  TranslationService.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 19.06.2024.
//

import Foundation

class TranslationService {
    // MARK: - URLs

    enum URLs {
        static let dictionaryapi = "https://api.dictionaryapi.dev/api/v2/entries/en/"
        static let deepLBaseUrl = "https://api-free.deepl.com/v2/translate"
    }

    // MARK: - TranslationResponse

    struct TranslationResponse: Codable {
        struct Translation: Codable {
            let detectedSourceLanguage: String
            let text: String
        }

        let translations: [Translation]
    }

    // MARK: - Public Methods

    func findDefinition(for word: String) async -> WordEntity? {
        let baseURL = URLs.dictionaryapi
        guard let searchURL = URL(string: baseURL + word) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: searchURL)
            let wordEntries = try JSONDecoder().decode([WordEntity].self, from: data)
            return wordEntries.first
        } catch {
            print("Failed to fetch or decode word entry: \(error)")
            return nil
        }
    }

    func translateText(searchedWord: String, targetLanguage: SupportedLanguage) async -> String {
        do {
            let translatedText = try await translateTextUsingDeepL(text: searchedWord, targetLanguage: targetLanguage)
            return translatedText
        } catch {
            print("Failed to translate text: \(error)")
            return ""
        }
    }

    // MARK: - Private Methods

    private func translateTextUsingDeepL(text: String, targetLanguage: SupportedLanguage) async throws -> String {
        guard let url = URL(string: URLs.deepLBaseUrl) else {
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
}
