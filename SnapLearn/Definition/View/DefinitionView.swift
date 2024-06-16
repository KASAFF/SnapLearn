import SwiftUI
import SwiftData

struct DefinitionsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DefinitionViewModel()
    @FocusState private var isInputActive: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""

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

            LanguagePickerView(selectedLanguage: .russian)
                .padding(.horizontal)
                .padding(.bottom, 5)
            Group {
                if let wordEntity = viewModel.wordEntity {
                    Text(wordEntity.word)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    if let translation = viewModel.translation {
                        Text("Translation: \(translation)")
                            .font(.headline)
                            .padding(.horizontal)
                    }
                    MeaningDetailView(meanings: wordEntity.meanings)
                }
            }

            Spacer()

            HStack {
                Button(action: {
                    isInputActive = false
                    Task {
                        await viewModel.fetchAndTranslate()
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
                    Task { saveWordForFutureLearning() }
                }) {
                    Text("Add to learn list")
                        .bold()
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .frame(height: 50)
                }
                .disabled(!viewModel.newWordFetched)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }

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

    func saveWordForFutureLearning() {
        guard let word = viewModel.wordModel, !word.wordText.isEmpty else { return }

        let wordText = word.wordText
        let predicate = #Predicate<WordModel> { wordModel in
            wordModel.wordText == wordText
        }

        do {
            let existingWords = try modelContext.fetch(.init(predicate: predicate))
            if existingWords.isEmpty {
                modelContext.insert(word)
                try modelContext.save()
                print("Word saved successfully")
            } else {
                alertMessage = "The word '\(word.wordText)' is already saved."
                showAlert = true
            }
        } catch {
            print("Failed to save word: \(error)")
            alertMessage = "Failed to save word: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
