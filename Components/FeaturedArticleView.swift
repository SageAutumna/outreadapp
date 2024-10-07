//
//  FeaturedArticleView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct FeaturedArticleView: View {
    @EnvironmentObject private var router: Router
    var animation: Namespace.ID
    
    let article: Article
    let isBookmarked: Bool
    let width: CGFloat
    var onTap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImageViewSkeleton(url: article.image?.src)
                .frame(width: width)
            .matchedGeometryEffect(id: "ArticleCover_\(article.id)", in: animation)
            
            Text(article.title)
                .font(.customFont(font: .poppins, style: .semiBold, size: .s14))
                .foregroundColor(Color("White100"))
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
        .frame(width: width)
        .cornerRadius(8)
        .onTapGesture {
            withAnimation {
                
                router.push(.altMetricsArticle(article))
            }
        }
    }
}

#Preview {
    FeaturedArticleView(animation: Namespace().wrappedValue,
                        article: TempData.shared.featuredArticles()[0],
                        isBookmarked: true,
                        width: 140)
        .frame(width: 140, height: 250)
        .background(Color(.mainBlue))
}
