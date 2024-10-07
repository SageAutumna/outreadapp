//
//  SearchTagView.swift
//  Outread
//
//  Created by iosware on 18/08/2024.
//

import SwiftUI

struct SearchTagView: View {
    let tag: String
    
    var onTap: ((String) -> Void)?
    
    var body: some View {
        HStack(spacing: 8) {
            Image(.iconLineUp)
                .resizable()
                .frame( width: 14, height: 8)
            Text(tag)
                .font(.customFont(font: .poppins, style: .regular, size: .s12))
                .foregroundColor(Color(.white60))
                .padding(.trailing, 10)
        }
        .frame(height: 28)
        .padding(.leading, 10)
        .overlay(RoundedRectangle(cornerRadius: 40).fill(Color(.white5)))
        .onTapGesture {
            onTap?(tag)
        }
    }
}

#Preview {
    SearchTagView(tag: "some keyword")
        .background(.black)
}
