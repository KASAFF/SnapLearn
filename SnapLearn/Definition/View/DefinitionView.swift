import SwiftUI
import SwiftData

struct DefinitionsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DefinitionViewModel()
    @FocusState private var isInputActive: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Constants

    enum Constants {
        static let enterWordPlaceholder = "Enter word"
        static let doneButton = "Done"
        static let findDefinitionButton = "Find Definition"
        static let addToLearnListButton = "Add to learn list"
        static let errorTitle = "Error"
        static let okButton = "OK"
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            inputSection
            wordDetailsSection
            Spacer()
            actionButtons
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(Constants.errorTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text(Constants.okButton))
            )
        }
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - Subviews

    private var inputSection: some View {
        VStack {
            HStack {
                TextField(Constants.enterWordPlaceholder, text: $viewModel.newWordText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .focused($isInputActive)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button(Constants.doneButton) {
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
        }
    }

    private var wordDetailsSection: some View {
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
    }

    private var actionButtons: some View {
        HStack {
            Button(action: {
                isInputActive = false
                Task {
                    await viewModel.fetchAndTranslate()
                }
            }) {
                Text(Constants.findDefinitionButton)
                    .bold()
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(height: 50)
            }

            Spacer()

            Button(action: {
                Task { saveWordForFutureLearning() }
            }) {
                Text(Constants.addToLearnListButton)
                    .bold()
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(height: 50)
            }
            .disabled(!viewModel.newWordFetched)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }

}

// MARK: - Private Methods

private extension DefinitionsView {
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
