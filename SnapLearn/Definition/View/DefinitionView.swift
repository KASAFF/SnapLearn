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
            Group {
                if let wordEntity = viewModel.wordEntity {
                    Text(wordEntity.word)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    MeaningDetailView(meanings: wordEntity.meanings)
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
