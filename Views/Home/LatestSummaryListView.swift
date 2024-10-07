//
//  LatestSummaryView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct LatestSummaryListView: View {
    @Namespace var animation
    @EnvironmentObject private var router: Router
    @Preference(\.isPremiumUser) var isPremiumUser
    @StateObject private var viewModel = ArticleListViewModel()
    
    @State private var contentHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 560.0 : 220.0

    var body: some View {
        VStack(spacing: 10) {
            SectionHeaderView(title: "Latest Summaries", needRightButton: false)
                .frame(height: 20)
                .padding(.bottom, isPad ? 20 : 0)

            HorizontalScrollWrapper(totalItems: viewModel.articles.count,
                                    itemsPerScreen: 3) {
                ForEach(viewModel.articles) { article in
                    let isBookmarked = viewModel.isArticleBookmarked(article.id)
                    SummaryItemView(animation: animation,
                                    article: article,
                                    isBookmarked: isBookmarked,
                                    onTap: {
                        viewModel.toggleBookmark(for: article.id)
                    })
                    .overlay(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                contentHeight = geo.size.height
                            }
                        }
                    )
                }
            }
            .frame(minHeight: contentHeight)
        }
        .frame(minHeight: contentHeight)
        .padding(.leading, 20)
        .onAppear {
            viewModel.loadLatestSummaries()
        }
    }

}

#Preview {
    LatestSummaryListView()
        .background(.black)
}
