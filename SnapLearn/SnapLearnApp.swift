//
//  SnapLearnApp.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI
import SwiftData

@main
struct SnapLearnApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(PersistenceController.shared.container)
        }
    }
}

import SwiftData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: WordModel.self, MeaningPresentationModel.self, Definition.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
}


