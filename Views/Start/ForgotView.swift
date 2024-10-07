//
//  ForgotView.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

struct ForgotView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var viewModel: AuthViewModel
    
    @State private var messagePopup: MessagePopup?
    @State private var loadingPopup: MessagePopup?
    
    var body: some View {
        ZStack{
            VStack {

                loginForm
                    .frame(maxWidth: isPad ? maxWidth / 1.5 : maxWidth)

                                
                bottomView
                
                Spacer()
            }
        }
        .background(Color(.mainBlue))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .loadingPopup(message: $loadingPopup)
        .messagePopup(message: $messagePopup)
        .onChange(of: viewModel.isLoading) { newValue in
            if newValue {
                loadingPopup = Constants.loadingPopup
            }
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            if let error = newValue {
                messagePopup = MessagePopup(message: error, isError: true)
            }
        }
//        .ignoresSafeArea()
    }
    
    private var loginForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Forgot password")
                    .modifier(LoginTitleTextStyle(size: .s24))
                
                Text("Let's remind your password")
                    .modifier(LoginSmallTextStyle())
            }
            
            VStack(alignment: .leading, spacing: 16) {
                FormFieldView(title: "Email", keyboardType: .emailAddress, value: $viewModel.email)
            }
            
            
            Button(action: {
                resetPassword()
            }) {
                Text("Send password")
                    .frame(maxWidth: .infinity)
                    .modifier(LoginButtonTextStyle(color: .black, padding: 14))
                    .background(.white)
                    .cornerRadius(10)
            }
            
        }
        .padding(.horizontal, 20)
    }

    var bottomView: some View {
        HStack(spacing: 6) {
            Spacer()
            Text("Already remembered your password?")
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
    
    func resetPassword() {
        Task { @MainActor in
            let result = await viewModel.resetPassword()
            if result {
                messagePopup = MessagePopup(message: "You should receive email with instructions soon", isError: false)
            }
        }
    }
}

#Preview {
    ForgotView()
        .environmentObject(Router())
        .environmentObject(AuthViewModel())
}
