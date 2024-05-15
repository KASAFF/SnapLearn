//
//  ContentView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DefinitionViewModel()

    var body: some View {
        TabView {
            DefinitionsView(viewModel: viewModel)
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
