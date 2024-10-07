//
//  ArticleSummaryView.swift
//  Outread
//
//  Created by iosware on 22/08/2024.
//

import SwiftUI

struct ArticleSummaryView: View {
    let text: String
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                Text(text)
                    .font(.customFont(font: .poppins, style: .regular, size: .s15))
                    .foregroundStyle(.white)
                    .background(.clear)
            }
            .background(.clear)
            .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
            VStack {
                LinearGradient(colors: Constants.scrollGradientColors,
                               startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
                Spacer().allowsHitTesting(false)
                LinearGradient(colors: Constants.scrollGradientColors,
                               startPoint: .bottom, endPoint: .top)
                .allowsHitTesting(false)
            }

        }
//        .background(Color(.white5))
        .cornerRadius(10)
        .padding(.init(top: 20, leading: 20, bottom: 20, trailing: 20))
    }
}

#Preview {
    ArticleSummaryView(text: TempData.shared.articles[0].defaultSummary[0].content[0])
        .background(Color(.mainBlue))
}
