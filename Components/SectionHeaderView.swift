//
//  SectionHeaderView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let actionTitle: String = "View all"
    var needRightButton: Bool = true
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.customFont(font: .poppins, style: .medium, size: .s18))
                .foregroundStyle(Color(.white100))
            
            Spacer()
            
            if(needRightButton) {
                Button(action: {
                    onTap?()
                }) {
                    HStack(spacing: 6) {
                        Text(actionTitle)
                            .font(.customFont(font: .poppins, style: .medium, size: .s12))
                            .foregroundStyle(Color(.white100))
                        
                        Image(systemName: "arrow.forward")
                            .frame(maxWidth: 18)
                            .font(.customFont(font: .poppins, style: .regular, size: .s16))
                            .foregroundColor(Color(.white100))
                    }
                }
                .padding(.trailing, 20)
            }
        }
        .frame(height: 24)
        .padding(.init(top: 10, leading: 0, bottom: 4, trailing: 0))
    }
}

#Preview {
    SectionHeaderView(title: "Latest Summaries", onTap: {})
        .background(.black)
}
