//
//  HomeView.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: ArticleListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ArticleListViewModel())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    HeaderView(needWelcome: true)
                        .frame(width: geometry.size.width)
                    
                    FeaturedListView()
                        .frame(width: geometry.size.width)
                    
                    CategoriesTagListView()
                        .frame(width: geometry.size.width)
                    
                    BookmarkedListView()
                        .frame(width: geometry.size.width)
                    
                    LatestSummaryListView()
                        .frame(width: geometry.size.width)
                    
//                    PlayListView(geometry: geometry)
//                        .frame(width: geometry.size.width)
                    
                    ForEach(viewModel.categories) { category in
                        ArticlesHorizontalListView(listType: .category(category), category: category)
                        .frame(width: geometry.size.width)
                    }
                }
                .frame(width: geometry.size.width)
                .padding(.top, 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height - Constants.tabbarHeight)
            .environment(\.geometry, geometry)
        }
        .ignoresSafeArea()
        .background(Color(.mainBlue))
        .onAppear {
            viewModel.loadCategories()
        }
    }
}

#Preview {
    HomeView()
}
