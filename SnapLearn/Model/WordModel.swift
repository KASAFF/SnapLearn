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
    let meanings: [MeaningPresentationModel]

    init(word: String, translation: String?, meanings: [MeaningPresentationModel]) {
        self.word = word
        self.translation = translation
        self.meanings = meanings
    }
}

@Model
final class MeaningPresentationModel {
    let partOfSpeech: String
    let definitions: [Definition]

    init(partOfSpeech: String, definitions: [Definition]) {
        self.partOfSpeech = partOfSpeech
        self.definitions = definitions
    }
}

@Model
final class Definition {
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
