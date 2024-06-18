//
//  NotAvailablePhotoView.swift
//  SnapLearn
//
//  Created by Aleksey Kosov on 02.06.2024.
//

import SwiftUI

struct NotAvailablePhotoView: View {

    var body: some View {
        VStack {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            Text("Photo not available")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }

}


