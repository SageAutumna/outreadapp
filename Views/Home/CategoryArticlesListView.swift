//
//  CategoryArticlesListView.swift
//  Outread
//
//  Created by iosware on 19/08/2024.
//

import SwiftUI
import Dependencies

struct CategoryArticlesListView: View {
    @StateObject private var viewModel = ArticleListViewModel()

    @State var category: Category

    private let articles: [Article] = []
    private let interCardSpacing: CGFloat = 20
    
    private let adaptiveColumn = UIDevice.current.userInterfaceIdiom == .pad ? [
        GridItem(.flexible(minimum: 250, maximum: 450)),
        GridItem(.flexible(minimum: 250, maximum: 450)),
        GridItem(.flexible(minimum: 250, maximum: 450))
    ] : [
        GridItem(.flexible(minimum: 100, maximum: 450)),
        GridItem(.flexible(minimum: 100, maximum: 450))
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: adaptiveColumn, 
                          spacing: interCardSpacing) {
                    ForEach(viewModel.articles) { article in
                        let isBookmarked = viewModel.isArticleBookmarked(article.id)
                        CategoryItemView(article: article, isBookmarked: isBookmarked, onTap: {
                            viewModel.toggleBookmark(for: article.id)
                        })
                            .frame(
                                width: width(geometry),
                                height: height(geometry)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color(.mainBlue))
        .onAppear {
            viewModel.loadArticles(for: .category(category))
        }
    }
    
    private func width(_ geometry: GeometryProxy) -> CGFloat {
        return isPad ? max(0, (geometry.size.width / 3 - 3 * interCardSpacing)) : max(0, (geometry.size.width / 2 - 2 * interCardSpacing))
    }
    
    private func height(_ geometry: GeometryProxy) -> CGFloat {
        let width = width(geometry)
        return isPad ? (width * 1.6 + interCardSpacing) : (width * 1.6 + interCardSpacing)
    }
}

#Preview {
    CategoryArticlesListView(category: Category(id: "1", name: "Health"))
        .environmentObject(ArticleListViewModel())
}
