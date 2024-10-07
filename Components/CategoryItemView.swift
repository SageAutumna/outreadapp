//
//  CategoryCardView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct CategoryItemView: View {
    @EnvironmentObject private var router: Router
    @Preference(\.isPremiumUser) var isPremiumUser
    
    let article: Article
    let isBookmarked: Bool
        
    var onTap: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                AsyncImageViewSkeleton(url: article.image?.src)
                    .frame(width: geometry.size.width,
                           height: geometry.size.width / Constants.coverAspectRatio)
                
                Text(article.title)
                    .font(.customFont(font: .poppins, style: .semiBold, size: .s12))
                    .foregroundColor(Color(.white100))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
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
            .background(.clear)
            .shadow(radius: 5)
            .onTapGesture {
                if isPremiumUser {
                    router.push(.article(article))
                } else {
                    router.isPaymentPresented = true
                }
            }
        }
    }
}

#Preview {
    CategoryItemView(article: TempData.shared.psychologyArticles()[0], isBookmarked: false)
        .frame(width: 170, height: 250)
        .background(.black)
}
