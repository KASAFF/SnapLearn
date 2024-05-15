//
//  WordListrView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI

struct WordListView: View {
    let words = ["Example", "Memory", "Learn"]

    var body: some View {
        List(words, id: \.self) { word in
            Text(word)
        }
        .navigationTitle("My Words")
    }
}
