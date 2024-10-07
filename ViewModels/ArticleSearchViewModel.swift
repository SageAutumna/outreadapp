//
//  ArticleSearchViewModel.swift
//  Outread
//
//  Created by iosware on 03/09/2024.
//

import SwiftUI
import Combine
import Dependencies

class ArticleSearchViewModel: ObservableObject {
    @Dependency(\.authManager) var authManager
    @Dependency(\.dataManager) var dataManager
    @Dependency(\.syncManager) var syncManager

    @Published var searchText = ""
    @Published var searchType: SearchType = .bestMatches
    @Published var articles: [Article] = []
    @Published var searchHistory: [String] = []
    @Published var bookmarkedArticleIds: Set<String> = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMoreArticles = true
    
    private var currentPage = 0
    private let pageSize = 20
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchPublisher()
        loadSearchHistory()
        updateBookmarks()
    }
    
    private func setupSearchPublisher() {
        $searchText
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task { [weak self] in
                    if !text.isEmpty {
	                        await self?.performSearch(keyword: text, saveKeyword: true)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func performSearch(keyword: String, saveKeyword: Bool = false) async {
        guard !keyword.isEmpty else {
            await MainActor.run {
                self.articles = []
            }
            return
        }
        
        let userId = authManager.currentUser?.id.uuidString
        
        let results = await Task.detached(priority: .userInitiated) { () -> [Article] in
            self.dataManager.searchArticles(keyword: keyword, searchType: self.searchType, userId: userId)
        }.value

        await MainActor.run {
            self.articles = results
            
            if !self.searchHistory.contains(keyword) {
                self.dataManager.addToSearchHistory(keyword: keyword)
                self.loadSearchHistory()
            }
        }
    }
    
    func loadSearchHistory() {
        searchHistory = dataManager.getSearchHistory()
        if searchText.isEmpty {
            Task {
                await performSearch(keyword: "a", saveKeyword: false)
            }
        }
    }
    
    func clearSearchHistory() {
        dataManager.clearSearchHistory()
        loadSearchHistory()
    }
    
    func selectSearchType(_ type: SearchType) {
        searchType = type
        Task {
            await performSearch(keyword: searchText)
        }
    }
    
    func isArticleBookmarked(_ articleId: String) -> Bool {
        bookmarkedArticleIds.contains(articleId)
    }

    @MainActor
    func toggleBookmark(for articleId: String) {
        guard let userId = authManager.currentUser?.id.uuidString else { return }
        dataManager.toggleBookmark(articleId, for: userId)
        if let index = articles.firstIndex(where: { $0.id == articleId }) {
            articles[index].isBookmarked.toggle()
        }
        updateBookmarks()
        
        Task {
            await syncManager.syncBookmarkedArticles()
        }
    }
    
    private func updateBookmarks() {
        guard let userId = authManager.currentUser?.id.uuidString else { return }
        let articleIds = articles.map { $0.id }
        let bookmarkedIds = Set(dataManager.fetchBookmarkedArticleIds(for: userId, articleIds: articleIds))
        self.bookmarkedArticleIds = bookmarkedIds
    }
}

enum SearchType: CaseIterable {
    case recent
    case popular
    case bestMatches
    
    var title: String {
        switch self {
        case .recent:
            return "Recent"
        case .popular:
            return "Popular"
        case .bestMatches:
            return "Best Matches"
        }
    }
}
