//
//  FormFieldView.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

struct FormFieldView: View {
    let title: String
    var keyboardType: UIKeyboardType = .default
    @Binding var value: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .modifier(LoginSmallTextStyle(color: .white))
            if isSecure {
                SecureFieldWithToggle(password: $value)
                    .overlay(
                      RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color(.fieldBorder), lineWidth: 1
                        )
                    )
            } else {
                TextField(title, text: $value)
                    .modifier(MainTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .overlay(
                      RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color(.fieldBorder), lineWidth: 1
                        )
                    )
            }
        }
    }
}

#Preview {
    FormFieldView(title: "Email", value: .constant("email"))
        .background(.black)
}
