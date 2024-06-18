//
//  MeaningDetailView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 09.06.2024.
//

import SwiftUI

struct MeaningDetailView: View {

    // MARK: - Properties

    let meanings: [MeaningEntity]?

    // MARK: - Initializer

    init(meanings: [MeaningEntity]?) {
        self.meanings = meanings
    }

    // MARK: - Constants

    enum Constants {
        static let partOfSpeechFont: Font = .title2
        static let partOfSpeechFontWeight: Font.Weight = .bold
        static let definitionFont: Font = .body
        static let exampleFont: Font = .footnote
        static let exampleColor: Color = .secondary
        static let synonymsFont: Font = .footnote
        static let synonymsColor: Color = .secondary
        static let maxLineLimit: Int = 3
        static let examplePrefix = "Example: "
        static let synonymsPrefix = "Synonyms: "
        static let verticalPadding: CGFloat = 5
        static let horizontalPadding: CGFloat = 10
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            if let meanings = meanings {
                ForEach(meanings.prefix(3), id: \.id) { meaning in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(meaning.partOfSpeech)
                            .font(Constants.partOfSpeechFont)
                            .fontWeight(Constants.partOfSpeechFontWeight)

                        ForEach(Array(meaning.definitions.prefix(2)), id: \.definition) { definition in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(definition.definition)
                                    .font(Constants.definitionFont)
                                    .lineLimit(Constants.maxLineLimit)
                                if let example = definition.example {
                                    Text(Constants.examplePrefix + example)
                                        .font(Constants.exampleFont)
                                        .foregroundColor(Constants.exampleColor)
                                        .lineLimit(Constants.maxLineLimit)
                                }
                                if !definition.synonyms.isEmpty {
                                    Text(Constants.synonymsPrefix + definition.synonyms.joined(separator: ", "))
                                        .font(Constants.synonymsFont)
                                        .foregroundColor(Constants.synonymsColor)
                                        .lineLimit(Constants.maxLineLimit)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Constants.verticalPadding)
                        }
                    }
                    .padding(.horizontal, Constants.horizontalPadding)
                    .padding(.vertical, Constants.verticalPadding)
                }
            }
        }
    }
}
