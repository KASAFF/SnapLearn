//
//  CardFront.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 19.05.2024.
//

import SwiftUI
import Kingfisher

struct CardFront: View {
    var word: WordModel
    let width: CGFloat
    let height: CGFloat
    @Binding var degree: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
            Text(word.wordText)
                .font(.largeTitle)
                .padding()
                .opacity(degree <= 90 || degree >= 270 ? 1 : 0)
        }
        .frame(width: width, height: height)
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}
