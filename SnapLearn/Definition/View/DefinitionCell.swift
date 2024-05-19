//
//  DefinitionCell.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI

struct DefinitionCell: View {

    let entity: DefinitionEntity

    var body: some View {
        HStack(alignment: .top) { // Ensure alignment is to the top to handle multiline text better.
            VStack(alignment: .leading) { // Align VStack content to the leading edge.
                Text(entity.definition)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading) // Ensure multiline text is also aligned to the leading.
                Text(entity.example ?? "")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.leading) // Ensure multiline text is also aligned to the leading.
            }
            Spacer() // Pushes all content to the left.
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure the frame of HStack is full width and content is aligned to the leading.
    }

    init(entity: DefinitionEntity) {
        self.entity = entity
    }

}

