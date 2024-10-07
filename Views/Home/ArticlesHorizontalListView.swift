//
//  ArticlesHorizontalListView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct ArticlesHorizontalListView: View {
    @EnvironmentObject private var router: Router
    @Preference(\.isPremiumUser) var isPremiumUser
    @StateObject private var viewModel = ArticleListViewModel()

    @State private var contentHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 620.0 : 260.0
        
    var listType: ArticleListType
    var title: String? = nil
    var category: Category? = nil
    
    var needHeader: Bool = true
    var needViewAll: Bool = true
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if needHeader {
                SectionHeaderView(title: title ?? category?.name ?? "",
                                  needRightButton: needViewAll,
                                  onTap: {
                    guard let category = category else { return }
                    router.push(.category(category))
                })
                .frame(height: 20)
                .padding(0)
                .padding(.bottom, isPad ? 20 : 0)
            }
            if viewModel.articles.isEmpty {
                Text("List is empty")
                    .font(.customFont(font: .poppins, style: .regular, size: .s14))
                    .foregroundColor(Color(.white60))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            } else {
                HorizontalScrollWrapper(totalItems: viewModel.articles.count,
                                        itemsPerScreen: 2.5,
                                        itemSpace: Constants.categoryItemSpacing) {
                    ForEach(viewModel.articles) { article in
                        let isBookmarked = viewModel.isArticleBookmarked(article.id)
                        CategoryItemView(article: article, isBookmarked: isBookmarked, onTap: {
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
        }
        .frame(minHeight: viewModel.articles.isEmpty ? 60 : contentHeight, maxHeight: viewModel.articles.isEmpty ? 60 : .infinity)
        .padding(.leading, 20)
        .onAppear {
            viewModel.loadArticles(for: listType)
        }
    }
}

struct CategoryListViewWrapper: View {
    var body: some View {
        GeometryReader { geometry in
            ArticlesHorizontalListView(listType: .all)
        }
    }
}


#Preview {
    CategoryListViewWrapper()
        .environmentObject(ArticleListViewModel())
        .background(.black)
}
