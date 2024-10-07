//
//  ArticleDetailViewModel.swift
//  Outread
//
//  Created by iosware on 30/08/2024.
//

import SwiftUI
import Combine
import Dependencies

class ArticleDetailViewModel: ObservableObject {
    @Published var article: Article
    @Published var currentReadingHeading: String?
    @Published var relatedArticles: [Article] = []
    @Published var relatedArticlesLoadingState: LoadingState = .idle
    @Published var featuredCategory: Category?
    
    @Preference(\.isPremiumUser) var isPremiumUser
    @Dependency(\.authManager) var authManager
    @Dependency(\.dataManager) var dataManager

    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error
    }
    
    init(article: Article) {
        self.article = article
        self.featuredCategory = dataManager.fetchCategory(name: Constants.featuredCategoryName)
        loadReadingProgress()
    }

    func loadReadingProgress() {
        fetchReadingProgress()
    }
    
    @MainActor
    func loadArticleDetails() {
         guard let userId = authManager.currentUser?.id.uuidString else { return }
         
        if let loadedArticle = dataManager.fetchArticleWithDetails(id: article.id, userId: userId) {
             self.article = loadedArticle
         }
     }
    
    @MainActor
    func loadRelatedArticles() {
        guard relatedArticlesLoadingState == .idle else { return }
        
        relatedArticlesLoadingState = .loading
        Task {
            if article.categories?.contains(Constants.featuredCategoryId) == true {
                let articles = await dataManager.fetchRelatedArticles(for: article.id, categoryId: Constants.featuredCategoryId, limit: 10)
                self.relatedArticles = articles
            } else {
                let articles = await dataManager.fetchRelatedArticles(for: article.id, categoryId: nil, limit: 10)
                self.relatedArticles = articles
            }
            self.relatedArticlesLoadingState = self.relatedArticles.isEmpty ? .error : .loaded
        }
    }
    
    @MainActor
    func loadRelatedAltMetricArticles() {
        guard relatedArticlesLoadingState == .idle else { return }
        
        relatedArticlesLoadingState = .loading
        
        Task {
            let articles = await dataManager.fetchRelatedAltMetricArticles(for: article.id, 
                                                                           userId: authManager.currentUserId,
                                                                           limit: isPremiumUser ? 20 : 5)
            self.relatedArticles = articles
            self.relatedArticlesLoadingState = articles.isEmpty ? .error : .loaded
        }
    }
    
    private func fetchReadingProgress() {
        currentReadingHeading = dataManager.getReading(articleId: article.id)
    }
    
    func updateReadingProgress(heading: String) {
        Task {
            await updateReading(heading: heading)
        }
    }
    @MainActor
    private func updateReading(heading: String) async {
        dataManager.updateReading(articleId: article.id, heading: heading)
        currentReadingHeading = heading
    }

    @MainActor
     func toggleBookmark() {
         guard let userId = authManager.currentUser?.id.uuidString else { return }
         dataManager.toggleBookmark(article.id, for: userId)
         article.isBookmarked.toggle()
     }
}
