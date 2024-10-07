//
//  ArticleFlashCard.swift
//  Outread
//
//  Created by iosware on 21/08/2024.
//

import SwiftUI

struct ArticleFlashCard: View {
    let text: String
    @State private var contentHeight: CGFloat = 260.0
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                Text(text)
                    .font(.customFont(font: .poppins, style: .regular, size: .s15))
                    .foregroundStyle(.white)
                    .background(.clear)
                    .overlay(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                contentHeight = geo.size.height
                            }
                        }
                    )
            }
            .frame(minHeight: contentHeight)
            .background(.clear)
            .padding(.init(top: 8, leading: 10, bottom: 10, trailing: 10))
            VStack {
//                LinearGradient(colors: Constants.scrollGradientColors,
//                               startPoint: .top, endPoint: .bottom)
//                .allowsHitTesting(false)
                Spacer().allowsHitTesting(false)
                LinearGradient(colors: Constants.scrollGradientColors,
                               startPoint: .bottom, endPoint: .top)
                .allowsHitTesting(false)
            }

        }
        .background(Color(.white5))
        .cornerRadius(10)
        .padding(0)
    }
}

#Preview {
    ArticleFlashCard(text: TempData.shared.articles[0].defaultSummary[0].content[0])
        .background(Color(.mainBlue))
        .frame(height: 300)
}
