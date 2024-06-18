//
//  SupportedLanguages.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 19.06.2024.
//

import Foundation

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
