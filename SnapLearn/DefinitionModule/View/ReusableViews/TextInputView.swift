//
//  TextInputView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 19.06.2024.
//

import SwiftUI

struct TextInputView: View {

    // MARK: - State Properties

    @Binding var text: String
    @FocusState private var isInputActive: Bool

    // MARK: - Constants

    enum Constants {
        static let enterWordPlaceholder = "Enter word"
        static let doneButton = "Done"
        static let textFieldBackgroundColor = Color(.systemGray6)
        static let textFieldCornerRadius: CGFloat = 8
        static let scanButtonWidth: CGFloat = 100
        static let scanButtonHeight: CGFloat = 56
    }

    var body: some View {
        HStack {
            TextField(Constants.enterWordPlaceholder, text: $text)
                .padding()
                .background(Constants.textFieldBackgroundColor)
                .cornerRadius(Constants.textFieldCornerRadius)
                .focused($isInputActive)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(Constants.doneButton) {
                            isInputActive = false
                        }
                    }
                }

            ScanButton(text: $text)
                .frame(width: Constants.scanButtonWidth, height: Constants.scanButtonHeight, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
