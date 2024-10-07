//
//  LoginView.swift
//  Outread
//
//  Created by iosware on 22/08/2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var viewModel: AuthViewModel
    
    @State var currentIndex: Int = 0
    @State var autoScroll: Bool = false
    @State var sidesScaling: CGFloat = 0.8
    @State var isWrap: Bool = false
    @State var time: TimeInterval = 2
    @State private var messagePopup: MessagePopup?
    @State private var loadingPopup: MessagePopup?

    private var items: [CarouselItem] = (0..<10).map { index in
        let nameSuffix = (index % 3) + 1
        return CarouselItem(id: UUID().uuidString, image: Image( "login-image-slide\(nameSuffix)"))
    }
    
    var body: some View {
        ZStack{
            VStack {
                carousel
                    .frame(maxWidth: isPad ? maxWidth / 1.5 : maxWidth)
                    .padding(.top, 40)
                
                loginForm
                    .frame(maxWidth: isPad ? maxWidth / 1.5 : maxWidth)
                
                SocialButtonsView()
                    .frame(maxWidth: isPad ? maxWidth / 1.5 : maxWidth)

                bottomView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.mainBlue))
        .ignoresSafeArea()
        .loadingPopup(message: $loadingPopup)
        .messagePopup(message: $messagePopup)
        .onChange(of: viewModel.isLoading) { newValue in
            if newValue {
                loadingPopup = Constants.loadingPopup
            }
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            if let error = newValue {
                loadingPopup = nil
                messagePopup = MessagePopup(message: error, isError: true)
            }
        }
    }
    
    private var carousel: some View {
        let height = UIScreen.main.bounds.height - UIScreen.main.bounds.minY
        let imageHeight = min((height * 245.0 / 850.0), 245.0)
        
        return AutoCarousel(items,
                            id: \.self,
                            index: $currentIndex,
                            spacing: Constants.interItemSpacing * 2,
                            headspace: Constants.autoCarouselSide,
                            sidesScaling: sidesScaling,
                            isWrap: isWrap,
                            autoScroll: autoScroll ? .active(time) : .inactive) { item in
            item.image
                .resizable()
                .aspectRatio(185/245, contentMode: .fit)
                .cornerRadius(18)
                .frame(height: imageHeight)
        }
        .frame(height: imageHeight + Constants.interItemSpacing)
        .padding(.top, 10)
        .onAppear{
            autoScroll.toggle()
        }
    }
    
    private var loginForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Text("Welcome to ")
                        .modifier(LoginTitleTextStyle())
                    Text("OUTREAD")
                        .modifier(LoginTitleBoldTextStyle())
                    
                }
                
                Text("Sign in to continue")
                    .modifier(LoginSmallTextStyle())
            }
            
            FormFieldView(title: "Email", keyboardType: .emailAddress, value: $viewModel.email)
            
            FormFieldView(title: "Password", value: $viewModel.password, isSecure: true)
            
            HStack {
                CheckboxButton(isChecked: $viewModel.rememberMe)
                Spacer()
//                Button("Forgot Password?") {
//                    router.push(.forgot)
//                }
//                .modifier(LoginSmallTextStyle(color: .white))
//                .fontWeight(.semibold)
            }
            
            Button(action: {
                Task {@MainActor in
                    await viewModel.signinWithValidation() { success in 
                        if success {
                            router.push(.main)
                        }
                    }
                }
            }) {
                Text("Log in")
                    .frame(maxWidth: .infinity)
                    .modifier(LoginButtonTextStyle(color: .black, padding: 14))
                    .background(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 20)
    }

    
    var bottomView: some View {
        HStack(spacing: 6) {
            Spacer()
            Text("Don’t have an account?")
                .modifier(LoginSmallTextStyle(color: Color(.white70)))
                .padding(.init( top: 0, leading: 0, bottom: 34, trailing: 3))
            
            Button(action: {
                router.push(.signup)
            }, label: {
                Text("Sign Up")
                    .modifier(LoginSmallTextStyle(color: .white))
                    .padding(.init( top: 0, leading: 3, bottom: 34, trailing: 2))
            })
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

struct CarouselItem: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let image: Image
    
    static func == (lhs: CarouselItem, rhs: CarouselItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
