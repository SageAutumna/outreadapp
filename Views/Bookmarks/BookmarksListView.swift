//
//  BookmarksListView.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

struct BookmarksListView: View {
    @ObservedObject var viewModel: ArticleListViewModel
    
    @EnvironmentObject private var router: Router
    
    init(viewModel: ArticleListViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    private var cardWidth: CGFloat {
        let divider: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 3.0 : 2.0
        
        return (((maxWidth - Constants.interItemSpacing * (UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2)) -  Constants.interItemSpacing) / divider)
    }
        
    // have to use fixed instead of adaptive because of lazyvstack
    private var adaptiveColumn = UIDevice.current.userInterfaceIdiom == .pad ? [
        GridItem(.flexible(minimum: (((UIScreen.main.bounds.width - Constants.interItemSpacing * 3) -  Constants.interItemSpacing) / 3),
                           maximum: UIScreen.main.bounds.width / 3)),
        GridItem(.flexible(minimum: (((UIScreen.main.bounds.width - Constants.interItemSpacing * 3) -  Constants.interItemSpacing) / 3),
                           maximum: UIScreen.main.bounds.width / 3)),
        GridItem(.flexible(minimum: (((UIScreen.main.bounds.width - Constants.interItemSpacing * 3) -  Constants.interItemSpacing) / 3),
                           maximum: UIScreen.main.bounds.width / 3))
    ] : [
        GridItem(.flexible(minimum: (((UIScreen.main.bounds.width - Constants.interItemSpacing * 2) -  Constants.interItemSpacing) / 2),
                           maximum: UIScreen.main.bounds.width / 2)),
        GridItem(.flexible(minimum: (((UIScreen.main.bounds.width - Constants.interItemSpacing * 2) -  Constants.interItemSpacing) / 2),
                           maximum: UIScreen.main.bounds.width / 2))
    ]
    
    var body: some View {
        ScrollView {
            SectionHeaderView(title: "Bookmark", needRightButton: false)
            .frame(height: 20)
            .padding(.bottom, isPad ? 20 : 0)
            
            if viewModel.articles.isEmpty {
                Text("List is empty")
                    .font(.customFont(font: .poppins, style: .regular, size: .s14))
                    .foregroundColor(Color(.white60))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
            } else {
                LazyVGrid(columns: adaptiveColumn, spacing: Constants.interItemSpacing) {
                    ForEach(viewModel.articles, id: \.self) { article in
                        let isBookmarked = isBookmarked(article.id)
                        BookmarkItemView(article: article,
                                         isBookmarked: isBookmarked,
                                         onTap: {
                            withAnimation {
                                toggleBookmark(article.id, isBookmarked: isBookmarked)
                            }
                        })
                        .frame(width: cardWidth, height: cardWidth * 1.8)
                        .id("bookmark_\(article.id)")
                    }
                }
                .frame(width: maxWidth - Constants.interItemSpacing * 2)
            }
        }
        .padding(.horizontal, 20)
        .background(Color(.mainBlue))
    }
    private func toggleBookmark(_ articleId: String, isBookmarked: Bool) {
        viewModel.toggleBookmarks(for: articleId, needReload: isBookmarked)
    }
    private func isBookmarked(_ articleId: String) -> Bool {
        return viewModel.isArticleBookmarked(articleId)
    }
}

#Preview {
    BookmarksListView(viewModel: ArticleListViewModel())
        .environmentObject(Router())
}
