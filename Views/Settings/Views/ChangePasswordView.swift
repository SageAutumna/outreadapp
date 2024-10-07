//
//  ChangePasswordView.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = ChangePasswodViewModel()
    
//    @State private var currentPassword = ""
    @State private var messagePopup: MessagePopup?
    @State private var loadingPopup: MessagePopup?
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)){
            VStack(alignment: .leading, spacing: 16) {
                Text("Change Password")
                    .modifier(MediumTextStyle(color:.white, size: .s22))
                Text("Your password must be at least 6 characters and should include a combination of numbers, letters and special characters.")
                    .modifier(RegularTextStyle())
                
//                FormFieldView(title: "Current Password", value: $currentPassword, isSecure: true)

                FormFieldView(title: "New Password", value: $viewModel.password, isSecure: true)

                FormFieldView(title: "Confirm Password", value: $viewModel.confirmPassword, isSecure: true)

//                HStack {
//                    Spacer()
//                    Button("Forgot Password?") {
//                        router.push(.forgot)
//                    }
//                    .modifier(LoginSmallTextStyle(color: .white))
//                    .fontWeight(.semibold)
//                }
                
                Button(action: {
                    changePassword()
                }) {
                    Text("Change Password")
                        .frame(maxWidth: .infinity)
                        .modifier(LoginButtonTextStyle(color: .black, padding: 14))
                        .background(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.mainBlue))
        .messagePopup(message: $messagePopup)
        .onChange(of: viewModel.errorMessage) { newValue in
            if let error = newValue {
                loadingPopup = nil
                messagePopup = MessagePopup(message: error, isError: true)
            }
        }
    }
    
    private func changePassword() {
        Task {
            await viewModel.changePasswordWithValidation { result in
                if result{
                    messagePopup = MessagePopup(message: "Password changed successfully", isError: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.router.pop()
                    }
                } else {
                    messagePopup = MessagePopup(message: "Password change failed", isError: true)
                }
            }
        }
    }
}

#Preview {
    ChangePasswordView()
}
