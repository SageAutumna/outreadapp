//
//  BookmarkedListView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct BookmarkedListView: View {
    @Namespace var animation
    @StateObject private var viewModel = ArticleListViewModel()

    @State private var currentIndex: Int = 0
    @State private var dynamicContentHeight: CGFloat = .zero
    @State private var verticalPadding: CGFloat = 40

    private let hstackSpacing: CGFloat = 10
    private let leadingSpacing: CGFloat = 20
    private let maxScale: CGFloat = 1.1
    
    private var heightReader: some View {
        GeometryReader { proxy in
            let h = proxy.size.height
            Color.clear
                .onAppear {
                    dynamicContentHeight = h + Constants.headerHeight + Constants.interItemSpacing
                }
                .onChange(of: h) { newVal in
                    dynamicContentHeight = newVal * maxScale
                }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let cardWidth: CGFloat = (totalWidth - (isPad ? 4 : 3) * (isPad ? hstackSpacing * 2 : hstackSpacing)) / (isPad ? 4 : 3)
            let cardHeight: CGFloat  = isPad ? (cardWidth / Constants.coverAspectRatio + 90) : cardWidth * 1.9
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: (isPad ? hstackSpacing * 2 : hstackSpacing)) {
                    ForEach(viewModel.articles) { article in
                        GeometryReader { proxy in
                            let scale = getScale(proxy: proxy, width: cardWidth)
                            let isBookmarked = viewModel.isArticleBookmarked(article.id)
                            FeaturedArticleView(animation: animation,
                                                article: article,
                                                isBookmarked: isBookmarked,
                                                width: cardWidth,
                                                onTap: {
                                viewModel.toggleBookmark(for: article.id)
                            })
                                .scaleEffect(.init(width: scale, height: scale))
                        }
                        .frame(width: cardWidth, height: cardHeight)
                        .padding(.leading, 20)
                        .padding(.vertical, verticalPadding)
                    }
                    Spacer()
                        .frame(width: cardWidth * 2)
                }
            }
            .frame(height: cardHeight)
            .background(heightReader)
            .onAppear {
                viewModel.loadTopScoreArticles()
                calculateVerticalPadding(cardHeight)
            }

        }
        .frame(height: dynamicContentHeight)
        .padding(.leading, 20)
        .padding(.top, verticalPadding)
    }
    
    private func calculateVerticalPadding (_ cardHeight: CGFloat) {
        verticalPadding = cardHeight / 5.4
    }
    
    private func getScale(proxy: GeometryProxy, width: CGFloat) -> CGFloat {
        let midPoint: CGFloat = width

        let viewFrame = proxy.frame(in: CoordinateSpace.global)
        
        var scale: CGFloat = 1.0
        let deltaXAnimationThreshold: CGFloat = width * 1.1
        
        let diffFromCenter = abs(midPoint - viewFrame.origin.x - deltaXAnimationThreshold * 0.5)
        if diffFromCenter < deltaXAnimationThreshold {
            scale = 1 + (deltaXAnimationThreshold - diffFromCenter) / UIScreen.main.bounds.width
        }
        
        return scale
    }
    
}

#Preview {
    BookmarkedListView()
}
