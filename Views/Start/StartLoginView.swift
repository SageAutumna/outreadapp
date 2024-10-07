//
//  StartLoginView.swift
//  Outread
//
//  Created by iosware on 22/08/2024.
//

import SwiftUI

struct StartLoginView: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        GeometryReader { geo in
            VStack() {
                Spacer()
                bottomBlock
                    .background(gradientView)
            }
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height + geo.safeAreaInsets.bottom)
            .background(
                Image(.backgroundLogin)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            )
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .background(Color(.mainBlue))
    }
    
    var gradientView: some View {
        VStack {
            Spacer().allowsHitTesting(false)
            LinearGradient(colors: Constants.loginGradientColors,
                           startPoint: .bottom, endPoint: .top)
            .frame(height: isPad ? 600 : 400)
            .allowsHitTesting(false)
        }
    }
    
    var bottomBlock: some View {
        VStack{
            Spacer()

            VStack(spacing: 0){
                Text("Learn powerful ideas")
                    .modifier(LoginTitleTextStyle())
                    .padding(0)
                HStack(spacing: 0) {
                    Text("from ")
                        .modifier(LoginTitleTextStyle())
                        .padding(0)
                    Text("Research Papers")
                        .modifier(LoginTitleBoldTextStyle())
                        .padding(0)
                }
            }
            .padding(0)
            
            HStack(alignment: .top, spacing: 20) {
                nextButton
                loginButton
            }
            .padding(20)
            
            bottomView
        }
    }
    
    var nextButton: some View {
        Button(action: {
            router.push(.startInfo)
        }, label: {
            Text("Next")
                .modifier(LoginButtonTextStyle())
                .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)

        })
        .buttonStyle(PlainButtonStyle())
         .overlay(
           RoundedRectangle(cornerRadius: 10)
             .inset(by: 0.50)
             .stroke(.white, lineWidth: 0.50)
         )
    }
    
    var loginButton: some View {
        Button(action: {
            router.push(.login)
        }, label: {
            HStack(spacing: 10) {
              Text("Log in")
                    .modifier(LoginButtonTextStyle(color: .black))
            }
            .padding(.init(top: 10, leading: 24, bottom: 10, trailing: 24))
            .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
            .background(.white)
            .cornerRadius(10)
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    var bottomView: some View {
        HStack {
            Text("Don’t have an account?")
                .modifier(LoginSmallTextStyle())
                .padding(.init( top: 0, leading: 0, bottom: 34, trailing: 3))
            Button(action: {
                router.push(.signup)
            }, label: {
                Text("Sign Up")
                    .modifier(LoginSmallTextStyle(color: .white))
                    .padding(.init( top: 0, leading: 3, bottom: 34, trailing: 2))
            })
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    StartLoginView()
}
