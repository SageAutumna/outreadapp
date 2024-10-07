//
//  SearchResultsList.swift
//  Outread
//
//  Created by iosware on 19/08/2024.
//

import SwiftUI

struct SearchResultsListView: View {
    @ObservedObject var viewModel: ArticleSearchViewModel
    
    let geometry: GeometryProxy
    
    private let interCardSpacing: CGFloat = 20
    
    private let adaptiveColumn = UIDevice.current.userInterfaceIdiom == .pad ? [
        GridItem(.adaptive(minimum: 300, maximum: 550)),
        GridItem(.flexible(minimum: 300, maximum: 550)),
        GridItem(.flexible(minimum: 300, maximum: 550)),
    ] : [
        GridItem(.adaptive(minimum: 100, maximum: 450)),
        GridItem(.flexible(minimum: 100, maximum: 450))
    ]
    
    var body: some View {
        ScrollView {
            if viewModel.articles.isEmpty {
                VStack(alignment: .center, spacing: 20) {
                    Text("No articles found")
                        .font(.customFont(font: .poppins, style: .regular, size: .s16))
                        .foregroundStyle(Color(.white100))
                    
                    Text("Check the spelling or try a new search")
                        .font(.customFont(font: .poppins, style: .regular, size: .s14))
                        .foregroundStyle(Color(.white60))
                }
            } else {
                LazyVGrid(columns: adaptiveColumn, spacing: interCardSpacing) {
                    ForEach(viewModel.articles) { article in
                        let isBookmarked = viewModel.isArticleBookmarked(article.id)
                        CategoryItemView(article: article,
                                         isBookmarked: isBookmarked,
                                         onTap: {
                            viewModel.toggleBookmark(for: article.id)
                        })
                        .frame(
                            width: width(geometry),
                            height: height(geometry)
                        )
                    }
                }
            }
        }
        .background(Color(.mainBlue))
        .ignoresSafeArea()
    }
    
    private func width(_ geometry: GeometryProxy) -> CGFloat {
        return isPad ? max(0, (geometry.size.width / 3 - interCardSpacing * 2)) :  max(0, (geometry.size.width / 2 - interCardSpacing))
    }
    
    private func height(_ geometry: GeometryProxy) -> CGFloat {
        let width = width(geometry)
        return isPad ? (width * 1.7) : (width * 1.7)
    }
}

struct SearchResultsListViewWrapper: View {
    var body: some View {
        GeometryReader { geometry in
            SearchResultsListView(
                viewModel: ArticleSearchViewModel(),
                geometry: geometry)
        }
    }
}


#Preview {
    SearchResultsListViewWrapper()
        .background(.black)
}
