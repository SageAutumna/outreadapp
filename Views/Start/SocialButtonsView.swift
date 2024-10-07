//
//  SocialButtonsView.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI
import AuthenticationServices

struct SocialButtonsView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isSignedIn {
            Text("Sucecss")
                .foregroundStyle(.clear)
                .onAppear{
                    router.push(.main)
                }
        }
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .background(Color(.white30))

                Text("Or log in with")
                    .font(.customFont(font: .poppins, style: .regular, size: .s12))
                    .foregroundColor(Color(.white40))

                // Line after the text
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .background(Color(.white30))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
          HStack(alignment: .top, spacing: 15) {
              Button(action: {
                  signInWithGoogle()
              }, label: {
                  HStack(spacing: 10) {
                      Image(.iconGoogle)
                          .foregroundColor(.white)
                      Text("Google")
                          .font(.customFont(font: .poppins, style: .regular, size: .s16))
                          .foregroundColor(.white)
                  }
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 14)
                  .background(Color(.mainBlue))
                  .overlay(
                      RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.buttonBorder), lineWidth: 1)
                  )
              })

              Button(action: {
                signInWithApple()
              }, label: {
                  HStack(spacing: 10) {
                      Image(systemName: "applelogo")
                          .foregroundColor(.white)
                      Text("Apple")
                          .font(.customFont(font: .poppins, style: .regular, size: .s16))
                          .foregroundColor(.white)
                  }
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 14)
                  .background(Color(.mainBlue))
                  .overlay(
                      RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.buttonBorder), lineWidth: 1)
                  )
              })

//              Button(action: {
//                  Task {
//                      await signInWithFacebook()
//                  }
//              }, label: {
//                  HStack(spacing: 10) {
//                      Image(.iconFacebook)
//                          .foregroundColor(.white)
//                      Text("Facebook")
//                          .foregroundColor(.white)
//                  }
//                  .frame(maxWidth: .infinity)
//                  .padding(.vertical, 14)
//                  .background(Color(.mainBlue))
//                  .overlay(
//                      RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color(.buttonBorder), lineWidth: 1)
//                  )
//              })

          }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    private func signInWithFacebook() {
        Task { @MainActor in
            let rootViewController = getRootViewController()
            await authViewModel.signInWithFacebook(presentingViewController: rootViewController)
        }
    }
    
    private func signInWithGoogle() {
        Task { @MainActor in
            let rootViewController = getRootViewController()
            await authViewModel.signInWithGoogle(presentingViewController: rootViewController)
        }
    }
    
    private func signInWithApple() {
        Task { @MainActor in
            await authViewModel.signInWithApple()
        }
    }
}

#Preview {
    SocialButtonsView()
        .environmentObject(AuthViewModel())
}
