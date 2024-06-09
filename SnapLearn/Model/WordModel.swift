//
//  WordCard.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftData

@Model
final class WordModel {
    let word: String
    let translation: String?
    let meanings: [MeaningEntry]

    init(word: String, translation: String?, meanings: [MeaningEntry]) {
        self.word = word.capitalized
        self.translation = translation?.capitalized
        self.meanings = meanings
    }
}

@Model
final class MeaningEntry {
    let partOfSpeech: String
    let antonyms: [String]
    let synonyms: [String]
    let definitions: [DefinitionEntry]

    init(partOfSpeech: String, antonyms: [String], synonyms: [String], definitions: [DefinitionEntry]) {
        self.antonyms = antonyms
        self.synonyms = synonyms
        self.partOfSpeech = partOfSpeech
        self.definitions = definitions
    }
}

@Model
final class DefinitionEntry {
    let definition: String
    let synonyms: [String]
    let antonyms: [String]
    let example: String?

    init(entity: DefinitionEntity) {
        self.definition = entity.definition
        self.synonyms = entity.synonyms
        self.antonyms = entity.antonyms
        self.example = entity.example
    }

    init(definition: String, synonyms: [String], antonyms: [String], example: String?) {
        self.definition = definition
        self.synonyms = synonyms
        self.antonyms = antonyms
        self.example = example
    }

}
