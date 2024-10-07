//
//  ArticleTagView.swift
//  Outread
//
//  Created by iosware on 20/08/2024.
//

import SwiftUI

struct ArticleTagView: View {
    let tag: String
    
    var body: some View {
        Text(tag)
            .font(.customFont(font: .poppins, style: .regular, size: .s10))
            .padding(10)
            .background(Color(.white10))
            .foregroundColor(Color(.white100))
            .cornerRadius(6)
    }}

#Preview {
    ArticleTagView(tag: "Entrepreneurship")
}
