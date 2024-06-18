//
//  ScanButton.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 12.05.2024.
//

import SwiftUI

struct ScanButton: View {
    @Binding var text: String

    var body: some View {
        HStack {
            ActionMenuView_UI(text: $text)
        }

    }

}

struct ActionMenuView_UI: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIView(context: Context) -> some UIView {


        let textFromCamera = UIAction.captureTextFromCamera(
            responder: context.coordinator,
            identifier: nil)
        let button = UIButton(primaryAction: textFromCamera)
        return button
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {

    }

    class Coordinator: UIResponder, UIKeyInput{
        var hasText: Bool {
            !parent.text.isEmpty
        }

        let parent: ActionMenuView_UI

        init(_ parent: ActionMenuView_UI){
            self.parent = parent
        }
        func insertText(_ text: String) {
            parent.text = text
        }

        func deleteBackward() { }
    }
}
