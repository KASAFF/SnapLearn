//
//  WordListViewModel.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 18.05.2024.
//

import SwiftData
//import SwiftUI
//
//@MainActor
//class WordListViewModel: ObservableObject {
//    @Published var words: [WordModel] = []
//
//    @Environment(\.modelContext) private var context
//
//    init() {
//        fetchWords()
//    }
//
//    func fetchWords() {
//        let fetchDescriptor = FetchDescriptor<WordModel>(sortBy: [SortDescriptor(\WordModel.word)])
//
//        do {
//            words = try context.fetch(fetchDescriptor)
//        } catch {
//            // Error handling here or make the function throw
//        }
//    }
//}
