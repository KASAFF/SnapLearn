//
//  DefinitionsView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI

struct DefinitionsView: View {

    @State var isShowingError = false

    @ObservedObject var viewModel: DefinitionViewModel

    var body: some View {
        VStack {
            HStack {
                TextField("Please enter a new word", text: $viewModel.newWordText)
                    .padding()
                    .border(Color.gray, width: 1)
                    .frame(maxWidth: .infinity)
                ScanButton(text: $viewModel.newWordText)
                    .frame(width: 100, height: 56, alignment: .leading)
            }
            Spacer()

            ScrollView {
                LazyVStack {
                    Text(viewModel.searchedWord)
                        .font(.title)
                    if let translation = viewModel.translation, !translation.isEmpty {
                        Text("Translation: \(translation)")
                    }
                    ForEach(viewModel.definitionEntities, id: \.id) { entity in
                        DefinitionCell(entity: entity)
                    }
                }
            }
            .padding()

            HStack {
                Button {
                    viewModel.fetchAndTranslate()
                } label: {
                    Text("Find Definition")
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .frame(height: 100)
                }

                Button {
                    // Implement the action to add a word for future learning
                } label: {
                    Text("Add to learn list")
                        .bold()
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .frame(height: 100)
                }
            }
            .frame(maxHeight: 100)
            .padding()
        }
        .padding()
        .alert("Не удалось найти слово", isPresented: $viewModel.isShowingError, actions: {
            Button("OK", role: .cancel) { }
        })
    }
}

#Preview {
    DefinitionsView(viewModel: .init())
}
