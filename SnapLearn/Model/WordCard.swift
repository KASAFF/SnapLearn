//
//  WordCard.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftData

@Model
class WordCard {
    let word: String
    let translation: String
    let definition: String
    let example: String

    init(word: String, translation: String, definition: String, example: String) {
        self.word = word
        self.translation = translation
        self.definition = definition
        self.example = example
    }
}
