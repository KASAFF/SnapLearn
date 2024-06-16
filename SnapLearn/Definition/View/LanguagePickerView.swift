//
//  LanguagePicker.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 16.06.2024.
//

import SwiftUI

struct LanguagePickerView: View {

    @State private var selectedLanguage: SupportedLanguage

    init(selectedLanguage: SupportedLanguage) {
        self.selectedLanguage = selectedLanguage
    }

    var body: some View {
        HStack {
            Spacer()
            Text("Translate to:")
                .lineLimit(1)
            Picker("My Language", selection: $selectedLanguage) {
                ForEach(SupportedLanguage.allCases, id: \.self) { language in
                    Text(language.displayName.appending(language.emoji))
                        .tag(language)
                }
            }
            .lineLimit(1)
            .pickerStyle(MenuPickerStyle())
            .padding(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
