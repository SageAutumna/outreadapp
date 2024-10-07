//
//  ArticleListViewModel.swift
//  Outread
//
//  Created by iosware on 30/08/2024.
//

import SwiftUI
import Combine
import Dependencies

class ArticleListViewModel: ObservableObject {
    @Dependency(\.authManager) var authManager
    @Dependency(\.dataManager) var dataManager
    @Dependency(\.syncManager) var syncManager
    
    @Preference(\.isPremiumUser) var isPremiumUser
    
    @Published var articles: [Article] = []
    @Published var featuredArticles: [Article] = []
    @Published var readingArticles: [Article] = []
    @Published var categories: [Category] = []
    @Published var featuredCategory: Category?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMoreArticles = true
    
    @Published var bookmarkedArticlesVersion: Int = 0
    
    @Published var selectedCategory: Category?
    @Published var bookmarkedArticleIds: Set<String> = []
    
    private var currentPage = 0
    private let pageSize = 50    
    
    init() {
        updateBookmarks()
    }
     
    func loadCategories() {
        categories = dataManager.fetchAllCategories()
        featuredCategory = categories.first { $0.name.lowercased() == Constants.featuredCategoryName }
    }
    
    func loadLatestSummaries() {
        guard !isLoading  else { return }
        isLoading = true
        errorMessage = nil
        let fetchedArticles = dataManager.fetchLatestSummaries()
        self.articles = fetchedArticles
        self.isLoading = false
    }

    func loadFeaturedArticles() {
        guard !isLoading else { return }
        updateBookmarks()
        isLoading = true
        errorMessage = nil
        if self.featuredCategory == nil {
            self.loadCategories()
        }
        
        let featuredCategory = self.featuredCategory ?? self.categories[0]
        let fetchedArticles = dataManager.fetchArticlesForCategory(featuredCategory.id,
                                                                   userId: authManager.currentUserId,
                                                                   page: currentPage,
                                                                   pageSize: pageSize)
        self.featuredArticles = fetchedArticles
        self.isLoading = false
    }
    
    func loadArticles(for listType: ArticleListType, needUser: Bool = true) {
        guard !isLoading else { return }
//        guard !isLoading && hasMoreArticles else { return }
        updateBookmarks()
        isLoading = true
        errorMessage = nil
        
        let userId = needUser ? authManager.currentUser?.id.uuidString : nil
        if listType == .continueReading {
            self.readingArticles = dataManager.fetchArticlesForList(listType: listType, 
                                                                    userId: userId, 
                                                                    page: currentPage,
                                                                    pageSize: pageSize)
        } else {
            let fetchedArticles = dataManager.fetchArticlesForList(listType: listType, 
                                                                   userId: userId,
                                                                   page: currentPage,
                                                                   pageSize: pageSize)
//        if self.currentPage == 0 {
            self.articles = fetchedArticles
//            debugPrint("articles.count=\(self.articles.count)")
//        } else {
//            self.articles.append(contentsOf: fetchedArticles)
//        }
        }
        self.isLoading = false
//        self.currentPage += 1
//        self.hasMoreArticles = fetchedArticles.count == self.pageSize
    }
    
    func loadContinueReading() {
        guard !isLoading else { return }
//        guard !isLoading && hasMoreArticles else { return }
        updateBookmarks()
        isLoading = true
//        errorMessage = nil
        
        
//        if self.currentPage == 0 {
        self.readingArticles.removeAll()
        self.readingArticles = dataManager.getArticlesWithReadingProgress(page: currentPage, pageSize: pageSize)
//        } else {
//            self.articles.append(contentsOf: fetchedArticles)
//        }
        self.isLoading = false
//        self.currentPage += 1
//        self.hasMoreArticles = fetchedArticles.count == self.pageSize
    }
    
    func loadTopScoreArticles() {
        isLoading = true
        articles = dataManager.fetchTopScoreArticles(userId: authManager.currentUser?.id.uuidString, limit: isPremiumUser ? 20 : 5)
        self.isLoading = false
    }
    func refreshArticles(for listType: ArticleListType) {
        currentPage = 0
        hasMoreArticles = true
        articles.removeAll()
        loadArticles(for: listType)
    }
    
    func toggleBookmarks(for articleId: String, needReload: Bool = false) {
        guard let userId = authManager.currentUser?.id.uuidString else { return }
        dataManager.toggleBookmark(articleId, for: userId)
        if let index = articles.firstIndex(where: { $0.id == articleId }), needReload {
            articles.remove(at: index)
        }

        if bookmarkedArticleIds.contains(articleId) {
            bookmarkedArticleIds.remove(articleId)
            articles.removeAll { $0.id == articleId }
        } else {
            bookmarkedArticleIds.insert(articleId)
            if let article = dataManager.fetchArticleWithDetails(id: articleId, userId: userId), articles.firstIndex(where: {$0.id == articleId}) == nil {
                articles.append(article)
            }
        }
        if !readingArticles.isEmpty {
            readingArticles.removeAll()
            loadArticles(for: .continueReading)
        }

        bookmarkedArticlesVersion += 1
        Task {
            await syncManager.syncBookmarkedArticles()
        }
    }
    
    func toggleBookmark(for articleId: String, needReload: Bool = false) {
        guard let userId = authManager.currentUser?.id.uuidString else { return }
        dataManager.toggleBookmark(articleId, for: userId)
        if bookmarkedArticleIds.contains(articleId) {
            bookmarkedArticleIds.remove(articleId)
        } else {
            bookmarkedArticleIds.insert(articleId)
        }
        bookmarkedArticlesVersion += 1
        Task {
            await syncManager.syncBookmarkedArticles()
        }
    }
    
    func isArticleBookmarked(_ articleId: String) -> Bool {
        return bookmarkedArticleIds.contains(articleId)
    }
    
    private func updateBookmarks() {
        guard let userId = authManager.currentUser?.id.uuidString else { return }
        let articleIds = articles.map { $0.id }
        let bookmarkedIds = Set(dataManager.fetchBookmarkedArticleIds(for: userId, articleIds: articleIds))
        self.bookmarkedArticleIds = bookmarkedIds
    }
}

enum ArticleListType: Equatable {
    case all
    case category(Category)
    case bookmarked
    case continueReading
    
    static func == (lhs: ArticleListType, rhs: ArticleListType) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all):
            return true
        case (.category(let lCategory), .category(let rCategory)):
            return lCategory.id == rCategory.id
        case (.bookmarked, .bookmarked):
            return true
        case (.continueReading, .continueReading):
            return true
        default:
            return false
        }
    }
}
