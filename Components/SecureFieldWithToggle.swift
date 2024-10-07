//
//  SecureFieldWithToggle.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

import SwiftUI

struct SecureFieldWithToggle: View {
    @Binding var password: String
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        ZStack {
            if isPasswordVisible {
                // Plain text field
                TextField("Password", text: $password)
                    .modifier(MainTextFieldStyle())
            } else {
                // Secure text field
                SecureField("Password", text: $password)
                    .modifier(MainTextFieldStyle())
            }
            
            // Overlay the eye icon button
            HStack {
                Spacer()
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
        .padding(0)
    }
}

#Preview {
    SecureFieldWithToggle(password: .constant("password"))
        .background(.black)
}
