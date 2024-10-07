//
//  SignupView.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var messagePopup: MessagePopup?
    @State private var loadingPopup: MessagePopup?
    
    var body: some View {
        ZStack{
            VStack {

                loginForm
                    .frame(maxWidth: isPad ? maxWidth / 1.5 : maxWidth)
                    .padding(.top, 64)
                
                SocialButtonsView()
                    .frame(maxWidth: isPad ? maxWidth / 1.5 : maxWidth)

                
                bottomView
            }
        }
        .background(Color(.mainBlue))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .loadingPopup(message: $loadingPopup)
        .messagePopup(message: $messagePopup)
        .onChange(of: authViewModel.isLoading) { newValue in
            if newValue {
                loadingPopup = Constants.loadingPopup
            }
        }
        .onChange(of: authViewModel.errorMessage) { newValue in
            if let error = newValue {
                loadingPopup = nil
                messagePopup = MessagePopup(message: error, isError: true)
            }
        }
    }
    
    private var loginForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Getting Started")
                    .modifier(LoginTitleTextStyle(size: .s24))
                
                Text("Let's create your account here")
                    .modifier(LoginSmallTextStyle())
            }
            
            VStack(alignment: .leading, spacing: 16) {
                FormFieldView(title: "Full Name", keyboardType: .namePhonePad, value: $authViewModel.fullName)
                                
                FormFieldView(title: "Email", keyboardType: .emailAddress, value: $authViewModel.email)
                
//                FormFieldView(title: "Mobile Number", keyboardType: .phonePad, value: $authViewModel.phone)
                                
                FormFieldView(title: "Password", value: $authViewModel.password, isSecure: true)
                
                FormFieldView(title: "Confirm password", value: $authViewModel.confirmPassword, isSecure: true)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await authViewModel.signupWithValidation() { success in
                        if success {
                            router.push(.main)
                        }
                    }
                }
            }) {
                Text("Sign up")
                    .frame(maxWidth: .infinity)
                    .modifier(LoginButtonTextStyle(color: .black, padding: 14))
                    .background(.white)
                    .cornerRadius(10)
            }
            .disabled(authViewModel.isLoading)
        }
        .padding(.horizontal, 20)
    }

    private var bottomView: some View {
        HStack(spacing: 6) {
            Spacer()
            Text("Already have an account?")
                .modifier(LoginSmallTextStyle(color: Color(.white70)))
                .padding(.init( top: 0, leading: 0, bottom: 34, trailing: 0))
            
            Button(action: {
                router.pop()
            }, label: {
                Text("Log in")
                    .modifier(LoginSmallTextStyle(color: .white))
                    .padding(.init( top: 0, leading: 3, bottom: 34, trailing: 2))
            })
            .buttonStyle(PlainButtonStyle())
            .padding(0)
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthViewModel())
}
