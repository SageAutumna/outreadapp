//
//  SearchTextFieldStyle.swift
//  Outread
//
//  Created by iosware on 18/08/2024.
//

import SwiftUI

struct SearchTextFieldStyle: TextFieldStyle {
    @State var icon: Image?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            if icon != nil {
                icon
                    .foregroundColor(.white)
            }
            configuration
                .foregroundColor(Color(.white60))
                .font(.customFont(font: .poppins, style: .regular, size: .s16))
        }
        .frame(height: 28)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background (
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.white10))
        )
    }
}
