//
//  WordEnty.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import Foundation

struct WordEntryWrapper: Codable {
    let entries: [WordEntity]
}

struct WordEntity: Codable, Identifiable {
    var id: String { word }
    let word: String
    let meanings: [MeaningEntity]
    let sourceUrls: [String]

    enum CodingKeys: CodingKey {
        case word
        case meanings
        case sourceUrls
    }
}

//struct Phonetic: Codable, Identifiable {
//    var id: UUID = UUID()
//    let audio: String?
//    let text: String?
//    let sourceUrl: String?
//}

struct MeaningEntity: Codable, Identifiable {
    var id: UUID = UUID()
    let partOfSpeech: String
    let definitions: [DefinitionEntity]
    let synonyms: [String]
    let antonyms: [String]

    enum CodingKeys: CodingKey {
        case partOfSpeech
        case definitions
        case synonyms
        case antonyms
    }
}

struct DefinitionEntity: Codable, Identifiable {
    let definition: String
    let synonyms: [String]
    let antonyms: [String]
    let example: String?
    var id: String { definition }
}
