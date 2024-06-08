//
//  DefinitionsView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI
import SwiftData

struct DefinitionsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DefinitionViewModel()
    @FocusState private var isInputActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("Enter word", text: $viewModel.newWordText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .focused($isInputActive)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isInputActive = false
                            }
                        }
                    }

                ScanButton(text: $viewModel.newWordText)
                    .frame(width: 100, height: 56, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity)

            HStack {
                if let translation = viewModel.wordModel?.translation {
                    Text("Translation: \(translation)")
                        .font(.headline)
                        .padding(.horizontal)
                }

                Spacer()

                Picker("Language", selection: $viewModel.selectedLanguage) {
                    ForEach(viewModel.languages, id: \.self) { language in
                        Text(language)
                            .textCase(.uppercase)
                            .tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.trailing)
            }
            .padding(.horizontal)
            .padding(.bottom, 5)

            if let wordEntry = viewModel.wordEntry {
                Text(wordEntry.word)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                ScrollView {
                    ForEach(Array(wordEntry.meanings.prefix(3).enumerated()), id: \.element.partOfSpeech) { index, meaning in // 2-3 meanings
                        VStack(alignment: .leading, spacing: 5) {
                            Text(meaning.partOfSpeech)
                                .font(.title2)
                                .bold()
                            
                            ForEach(Array(meaning.definitions.prefix(2).enumerated()), id: \.element.definition) { index, definition in // 1-2 definitions per meaning
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
                                .padding(.vertical, 5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
            }

            Spacer()

            HStack {
                Button(action: {
                    isInputActive = false
                    Task {
                        viewModel.fetchAndTranslate()
                    }
                }) {
                    Text("Find Definition")
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .frame(height: 50)
                }

                Spacer()

                Button(action: {
                    Task { await saveWordForFutureLearning() }
                }) {
                    Text("Add to learn list")
                        .bold()
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .frame(height: 50)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()

        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }

    }

    func saveWordForFutureLearning() async {
        guard let word = viewModel.wordModel, !word.word.isEmpty else { return }

        do {
            modelContext.insert(word)
            try modelContext.save()
        } catch {
            print("Failed to save word: \(error)")
        }
    }
    
}


//#Preview {
//    DefinitionsView(viewModel: .init())
//}
