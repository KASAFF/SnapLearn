//
//  CardFront.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 19.05.2024.
//

import SwiftUI

struct CardFront: View {
    var word: WordModel
    let width: CGFloat
    let height: CGFloat
    @Binding var degree: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 6)

            Text(word.word)
                .font(.largeTitle)
                .padding()
                .opacity(degree <= 90 || degree >= 270 ? 1 : 0)
        }
        .frame(width: width, height: height)
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}
