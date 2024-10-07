//
//  StartLoginInfoView.swift
//  Outread
//
//  Created by iosware on 22/08/2024.
//

import SwiftUI

struct StartLoginInfoView: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                VStack {
                    Spacer()
                    
                    Image(.loginImage1)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        VStack(spacing:4) {
                            HStack(spacing: 0) {
                                Text("Read")
                                    .modifier(LoginTitleBoldTextStyle(size: .s28))
                                Text(" or ")
                                    .modifier(LoginTitleTextStyle(size: .s28))
                                Text("Listen")
                                    .modifier(LoginTitleBoldTextStyle(size: .s28))
                                Text(" on the")
                                    .modifier(LoginTitleTextStyle(size: .s28))
                            }
                            HStack(spacing: 0) {
                                Text("go ")
                                    .modifier(LoginTitleTextStyle(size: .s28))
                                Text("anytime, anywhere")
                                    .modifier(LoginTitleBoldTextStyle(size: .s28))
                            }
                        }
                        
                        Button(action: {
                            router.push(.login)
                        }, label: {
                          Text("Log in")
                                .modifier(LoginButtonTextStyle(color: .black))
                                .frame(maxWidth: .infinity)
                            .background(.white)
                            .cornerRadius(10)
                        })
                        .buttonStyle(PlainButtonStyle())
                        .padding(.init(top: 34, leading: 20, bottom: 40, trailing: 20))
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(.mainBlue))
                            .frame(width: geometry.size.width, height: geometry.size.height / 3.2)
                            .padding(0)
                    )
                    .ignoresSafeArea()
                    
                }
            }
        }
        .background(Color(.lightBlue))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    StartLoginInfoView()
}
