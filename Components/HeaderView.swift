//
//  HeaderView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct HeaderView: View {
    var title: String? = nil
    var needWelcome: Bool = false
    
    var body: some View {
        HStack() {
            WelcomeUserView(needWelcome: needWelcome)
            Spacer()
            if let title = title {
                Text(title)
                    .font(.customFont(font: .poppins, style: .medium, size: .s18))
                    .foregroundColor(Color(.white100))
                Spacer()
            }
            
//            BookmarkButton {
//                print()
//            }
        }
        .padding(.init(top: 50, leading: 20, bottom: 0, trailing: 20))
    }
}

#Preview {
    HeaderView(title: "Home", needWelcome: true)
}
