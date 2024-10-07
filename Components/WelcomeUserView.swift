//
//  WelcomeUserView.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI
import Dependencies

struct WelcomeUserView: View {
    let needWelcome: Bool
    @Dependency(\.authManager) var authManager
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
//            DefaultAvatar()
////            Image(.avatar)
////                .resizable()
////                .aspectRatio(1, contentMode: .fill)
//                .frame(width: 48, height: 48)
//                .cornerRadius(24)
            if needWelcome {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Welcome  🎉")
                        .font(.customFont(font: .poppins, style: .regular, size: .s14))
                        .fontWeight(.regular)
                        .foregroundStyle(.white)
                    Text(authManager.name)
                        .font(authManager.name.contains("@") ? .customFont(font: .poppins, style: .medium, size: .s12) : .customFont(font: .poppins, style: .semiBold, size: .s18))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
        }
        
    }
}

#Preview {
    WelcomeUserView(needWelcome: true)
}
