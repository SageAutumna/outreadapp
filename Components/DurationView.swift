//
//  DurationView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct DurationView: View {
    let duration: Int
    
    var body: some View {
        Text("\(duration) min")
            .font(.customFont(font: .poppins, style: .regular, size: .s10))
            .padding(8)
            .background(Color(.white10))
            .foregroundColor(Color(.white100))
            .cornerRadius(8)
    }
}

#Preview {
    DurationView(duration: 10)
        .background(.black)
}
