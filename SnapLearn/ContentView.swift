//
//  ContentView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext

    var body: some View {
        TabView {
            DefinitionsView()
                .tabItem {
                    Label("Definitions", systemImage: "book.fill")
                }

            WordListView()
                .tabItem {
                    Label("My Words", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
