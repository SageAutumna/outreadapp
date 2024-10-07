//
//  CategoriesTagListView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI
import Dependencies

struct CategoriesTagListView: View {
    @EnvironmentObject private var router: Router

    @EnvironmentObject var viewModel: ArticleListViewModel
    
    @State private var selectedCategoryId: String?
    @State private var categories: [Category] = []
    
    var body: some View {
        HorizontalScroll{
            ForEach(viewModel.categories) { category in
                CategoryTagView(
                    category: category,
                    selectedCategoryId: $selectedCategoryId
                )
                .onTapGesture {
                    selectedCategoryId = category.id
                    router.push(.category(category))
                }
            }
        }
        .onAppear {
            viewModel.loadCategories()
        }
    }
}

#Preview {
    CategoriesTagListView()
}
