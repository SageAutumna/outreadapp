//
//  SplashView.swift
//  Outread
//
//  Created by iosware on 20/08/2024.
//

import SwiftUI
import Lottie

struct SplashView: View {
    @State var splashScreen  = true
    
    var body: some View {
        ZStack{
            VStack{
                LottieView(animation: .named("book-reading"))
                  .looping()
                  .padding(.bottom, 20)
                Text("Loading ...")
                    .font(.title)
                    .foregroundStyle(Color(.white100))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.mainBlue))
        .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
