//
//  SummaryCardView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct SummaryItemView: View {
    @EnvironmentObject private var router: Router
    @Preference(\.isPremiumUser) var isPremiumUser
    var animation: Namespace.ID
    let article: Article
    let isBookmarked: Bool
    var onTap: (() -> Void)?
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading) {
                AsyncImageViewSkeleton(url: article.image?.src)
                    .frame(width: geometry.size.width,
                           height: geometry.size.width / Constants.coverAspectRatio,
                           alignment: .top)
                    .matchedGeometryEffect(id: "ArticleCover_\(article.id)", in: animation)

                Text(article.title)
                    .font(.customFont(font: .poppins, style: .semiBold, size: .s12))
                    .foregroundColor(Color(.white100))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .matchedGeometryEffect(id: "ArticleTitle_\(article.id)", in: animation)
                
                HStack {
                    DurationView(duration: article.estimatedReadingTime)
                    Spacer()
                    IconButton(width: 28,
                               icon: Image(.iconBookmark),
                               selectedIcon: Image(.iconBookmarkFilled),
                               isSelected: isBookmarked) {
                        onTap?()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onTapGesture {
                withAnimation {
                    if isPremiumUser {
                        router.push(.article(article))
                    } else {
                        router.isPaymentPresented = true
                    }
                }
            }
        }
    }
}

#Preview {
    SummaryItemView(animation: Namespace().wrappedValue,
                    article: TempData.shared.summaryArticles()[0],
                    isBookmarked: false)
        .frame(width: 140, height: 260)
        .background(Color(.mainBlue))
}
