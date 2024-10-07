//
//  CheckboxButton.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

struct CheckboxButton: View {
    @Binding var isChecked: Bool
    var title: String = "Remember me"
    
    @State private var animationAmount: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0)) {
                isChecked.toggle()
                animationAmount = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0)) {
                    animationAmount = 1.0
                }
            }
        }) {
            HStack(spacing: 9) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square" )
                    .foregroundColor(isChecked ? .white : Color(.white60))
                    .scaleEffect(animationAmount)
                                        .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0), value: isChecked)
                
                Text(title)
                    .modifier(LoginSmallTextStyle(color: .white))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CheckboxButton(isChecked: .constant(true))
        .background(.black)
}
