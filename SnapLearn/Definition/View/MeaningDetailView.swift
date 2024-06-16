//
//  MeaningDetailView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 09.06.2024.
//

import SwiftUI

struct MeaningDetailView: View {

    let meanings: [MeaningEntity]?

    init(meanings: [MeaningEntity]?) {
        self.meanings = meanings
    }

    var body: some View {
        
        ScrollView {
            if let meanings {
                ForEach(meanings.prefix(3), id: \.id) { meaning in // 2-3 meanings
                    VStack(alignment: .leading, spacing: 5) {
                        Text(meaning.partOfSpeech)
                            .font(.title2)
                            .bold()
                        
                        ForEach(Array(meaning.definitions.prefix(2)), id: \.definition) { definition in // 1-2 definitions per meaning
                            VStack(alignment: .leading, spacing: 3) {
                                Text(definition.definition)
                                    .font(.body)
                                    .lineLimit(3)
                                if let example = definition.example {
                                    Text("Example: \(example)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                if !definition.synonyms.isEmpty {
                                    Text("Synonyms: \(definition.synonyms.joined(separator: ", "))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }
        }
    }

}
