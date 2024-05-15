//
//  WordEnty.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import Foundation

struct WordEntryWrapper: Codable {
    let entries: [WordEntry]
}

struct WordEntry: Codable, Identifiable {
    var id: String { word }
    let word: String
    let phonetics: [Phonetic]
    let meanings: [Meaning]
    let sourceUrls: [String]
}

struct Phonetic: Codable {
    let audio: String?
    let text: String?
    let sourceUrl: String?
}

struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [DefinitionEntity]
    let synonyms: [String]
    let antonyms: [String]
}

struct DefinitionEntity: Codable, Identifiable {
    let definition: String
    let synonyms: [String]
    let antonyms: [String]
    let example: String?
    var id: String { definition }
}
