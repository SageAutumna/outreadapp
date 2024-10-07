//
//  ContentCardView.swift
//  Outread
//
//  Created by iosware on 26/08/2024.
//

import SwiftUI

struct ContentCardView: View {
    let article: Article
    let summary: Article.Summary
    let cardHeight: CGFloat
    var isLast: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(summary.heading ?? "")
                .modifier(SemiboldTextStyle(color: .white, size: .s18))

            Text(summary.content[0])
                .modifier(RegularTextStyle(color: .white, size: .s14))
                .foregroundStyle(.white)
                .padding()
                .background(Color(.white5))
                .cornerRadius(10)
                .shadow(radius: 5)
            if isLast {
                infoView
            }
            Spacer()
        }
        .frame(height: cardHeight)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(Color(.mainBlue))
    }
    
    private var infoView: some View {
        HStack{
            VStack(alignment: .leading, spacing: 0){
                Text("DOI:")
                    .font(.customFont(font: .poppins, style: .light, size: .s12))
                    .foregroundStyle(Color(.white80))
                    .multilineTextAlignment(.center)
                
                Text("\(article.doi)")
                    .font(.customFont(font: .poppins, style: .light, size: .s12))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

            }
            .padding(.trailing, 20)

            Spacer()

            VStack(alignment: .trailing, spacing: 0){
                Text("Altmetric score:")
                    .font(.customFont(font: .poppins, style: .light, size: .s12))
                    .foregroundStyle(Color(.white80))
                    .multilineTextAlignment(.center)
                                        
                Text("\(Int(article.altMetricScore))")
                    .font(.customFont(font: .poppins, style: .light, size: .s12))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.leading, 20)
        }
        .padding(.top, 20)
    }

}

#Preview {
    ContentCardView(article: TempData.shared.articles[0],
                    summary: TempData.shared.articles[0].oneCardSummary,
                    cardHeight: 200)
        .frame(width: 300)
}
