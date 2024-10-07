//
//  ContinueReadingListView.swift
//  Outread
//
//  Created by iosware on 07/09/2024.
//

import SwiftUI

struct ContinueReadingListView: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ArticleListViewModel

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
            if viewModel.readingArticles.isEmpty {
                Text("List is empty")
                    .font(.customFont(font: .poppins, style: .regular, size: .s14))
                    .foregroundColor(Color(.white60))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            } else {
                HorizontalScrollWrapper(totalItems: viewModel.readingArticles.count,
                                        itemsPerScreen: 2.5,
                                        itemSpace: Constants.categoryItemSpacing) {
                    ForEach(viewModel.readingArticles) { article in
                        let isBookmarked = viewModel.isArticleBookmarked(article.id)
                        CategoryItemView(article: article, isBookmarked: isBookmarked, onTap: {
                            withAnimation {
                                viewModel.toggleBookmark(for: article.id)
                            }
                        })
                            .overlay(
                                GeometryReader { geo in
                                    Color.clear.onAppear {
                                        contentHeight = geo.size.height
                                    }
                                }
                            )
                            .id("continue_reading_\(article.id)")
                    }
                    if viewModel.hasMoreArticles {
                        ProgressView()
                            .onAppear {
                                viewModel.loadArticles(for: listType)
                            }
                    }
                }
                .frame(minHeight: contentHeight)
            }
        }
        .frame(minHeight: viewModel.readingArticles.isEmpty ? 60 : contentHeight, maxHeight: viewModel.readingArticles.isEmpty ? 60 : .infinity)
        .padding(.leading, 20)
        .onAppear {
            viewModel.loadArticles(for: listType)
        }
    }
}

struct ContinueReadingListViewWrapper: View {
    var body: some View {
        GeometryReader { geometry in
            ContinueReadingListView(viewModel: ArticleListViewModel(), listType: .continueReading)
        }
    }
}


#Preview {
    ContinueReadingListViewWrapper()
        .environmentObject(Router())
        .background(.black)
}
