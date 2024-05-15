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


        // A UIButton can hold the menu, it is a long press to get it to come up
        let textFromCamera = UIAction.captureTextFromCamera(
            responder: context.coordinator,
            identifier: nil)
        let button = UIButton(primaryAction: textFromCamera)
        return button
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
    //Making the Coordinator a UIResponder as! UIKeyInput gives access to the text
    class Coordinator: UIResponder, UIKeyInput{
        var hasText: Bool {
            !parent.text.isEmpty
        }

        let parent: ActionMenuView_UI

        init(_ parent: ActionMenuView_UI){
            self.parent = parent
        }
        func insertText(_ text: String) {
            //Update the @Binding
            parent.text = text
        }

        func deleteBackward() { }
    }
}
