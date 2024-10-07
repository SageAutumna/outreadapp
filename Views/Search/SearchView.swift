//
//  SearchView.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = ArticleSearchViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        HeaderView(title: "Search")
                            .frame(width: geometry.size.width)
                        
                        TextField("Search",
                                  text: $viewModel.searchText,
                                  prompt: Text("Search").foregroundColor(Color(.white60)))
                        .focused($isTextFieldFocused)
                        .textFieldStyle(SearchTextFieldStyle(icon: Image(systemName: "magnifyingglass")))
                        .padding(.top, 10)

                        if viewModel.searchText.isEmpty {
                            FlowLayout(mode: .scrollable,
                                       items: viewModel.searchHistory,
                                       itemSpacing: 8) {
                                SearchTagView(tag: $0) { key in
                                    viewModel.searchText = key
                                }
                            }
                           .frame(width: geometry.size.width)
                           .padding(0)
                        }

                        
                        SearchSegmentFilter(width: geometry.size.width)
                            .frame(width: geometry.size.width)
                            .padding(.bottom, 8)
                        
                        SearchResultsListView(viewModel: viewModel,
                                              geometry: geometry)
                            .frame(width: geometry.size.width)
                            .padding(.top, isPad  ? 20 : 10)
                        
                    }
                    .frame(width: geometry.size.width)
                    .padding(.top, 10)
                }
                .frame(width: geometry.size.width, height: max(0, geometry.size.height - Constants.tabbarHeight))
            }
            .padding(.horizontal, 20)
            .ignoresSafeArea()
            .background(Color(.mainBlue))
            .onAppear{
//                isTextFieldFocused = true
                viewModel.loadSearchHistory()
            }
        }
}

#Preview {
    SearchView()
        .background(.blue)
}
