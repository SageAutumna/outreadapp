//
//  BookmarksView.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI

struct BookmarksView: View {
    @StateObject var viewModel = ArticleListViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                HeaderView(needWelcome: true)
                    .frame(width: maxWidth)

                ContinueReadingListView(viewModel: viewModel,
                                           listType: .continueReading,
                                           title: "Continue reading",
                                           needViewAll: false)

                BookmarksListView(viewModel: viewModel)
            }
            .frame(maxHeight: .infinity)
            .padding(.top, 10)
        }
        .frame(maxHeight: .infinity)
        .background(Color(.mainBlue))
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            viewModel.loadArticles(for: .continueReading, needUser: true)
            viewModel.loadArticles(for: .bookmarked, needUser: true)
        }
    }
}

#Preview {
    BookmarksView()
}
