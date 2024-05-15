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
    @Published var translation: String?
    @Published var isShowingError = false
    @Published var definitionEntities: [DefinitionEntity] = []
    @Environment(\.modelContext) var modelContext

    func fetchAndTranslate() {
        let dispatchGroup = DispatchGroup()
        var definitions: [DefinitionEntity] = []
        var translation: String?

        dispatchGroup.enter()
        Task {
            definitions = await findDefinition()
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        Task {
            translation = await translateText(targetLang: "ru")
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.definitionEntities = definitions
            self.translation = translation
        }
    }

    func saveWordForFutureLearning(word: WordEntry) async {
        modelContext
    }
}

// MARK: - Private Methods

private extension DefinitionViewModel {

    func findDefinition() async -> [DefinitionEntity] {
        let baseURL = URLs.dictionaryapi
        self.searchedWord = newWordText
        guard let searchURL = URL(string: baseURL + searchedWord) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: searchURL)
            let wordEntries = try JSONDecoder().decode([WordEntry].self, from: data)
            return Array(wordEntries.first?.meanings.first?.definitions.prefix(5) ?? [])
        } catch {
            isShowingError = true
            print("Failed to fetch or decode word entry: \(error)")
            return []
        }
    }

    func translateText(targetLang: String) async -> String? {
        let encodedText = searchedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=en|\(targetLang)"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let translationResult = try JSONDecoder().decode(TranslationResult.self, from: data)
            return translationResult.responseData.translatedText
        } catch {
            print("Failed to translate text: \(error)")
            return nil
        }
    }
    
}

struct TranslationResult: Codable {
    let responseData: ResponseData
}

struct ResponseData: Codable {
    let translatedText: String
}
