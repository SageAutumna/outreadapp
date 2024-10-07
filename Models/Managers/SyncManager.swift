//
//  SyncManager.swift
//  Outread
//
//  Created by iosware on 29/08/2024.
//

import Foundation
import Combine
import Supabase

class SyncManager {
    private let supabaseClient = SupabaseManager.shared.client
    private let coreDataManager = CoreDataManager.shared
    
    init() {}
    
    func startSyncing() async {
//        Task.detached(priority: .background) {
            await self.performFullSync()
//        }
    }
    
    private func performFullSync() async {
        await syncCategories()
        await syncArticles()
        await syncArticleToCategory()
        await syncImages()
        await syncBookmarkedArticles()
    }
    
    private func syncCategories() async {
        do {
            let categories: [Category] = try await supabaseClient.from("Catergory").select().execute().value
            await coreDataManager.saveOrUpdateCategories(categories)
            debugPrint("Synced \(categories.count) categories: \(categories.map({$0.name}).joined(separator: ","))")
        } catch {
            debugPrint("Error syncing categories: \(error)")
        }
    }
    
    private func syncArticles() async {
            do {
                let batchSize = 100
                var offset = 0
                var hasMore = true
                
                while hasMore {
                    let articles: [Article] = try await supabaseClient
                        .from("Article")
                        .select()
                        .range(from: offset,to: offset + batchSize - 1)
                        .execute()
                        .value
                    
                    await coreDataManager.saveOrUpdateArticles(articles)
                    debugPrint("Synced \(articles.count) articles")
                    
                    offset += batchSize
                    hasMore = articles.count == batchSize
                }
            } catch {
                debugPrint("Error syncing articles: \(error)")
            }
        }

    
    private func syncArticleToCategory() async {
        do {
            // Clean the ArticleToCategoryMO table before syncing
            await coreDataManager.cleanArticleToCategoryTable()
            
            struct ArticleToCategory: Codable {
                let A: String  // articleId
                let B: String  // categoryId
            }
            
            let articleToCategories: [ArticleToCategory] = try await supabaseClient.from("_ArticleToCatergory").select().execute().value
            await coreDataManager.saveOrUpdateArticleToCategories(articleToCategories.map { ($0.A, $0.B) })
            debugPrint("Synced \(articleToCategories.count) article-category relationships")
        } catch {
            debugPrint("Error syncing article to category relationships: \(error)")
        }
    }

    private func syncImages() async {
        do {
            let images: [ArticleImage] = try await supabaseClient.from("Image").select().execute().value
            await coreDataManager.saveOrUpdateArticleImages(images)
            debugPrint("Synced \(images.count) images")
        } catch {
            debugPrint("Error syncing images: \(error)")
        }
    }
    
    func syncBookmarkedArticles() async {
        do {
            let bookmarkedArticles: [BookmarkedArticle] = try await supabaseClient.from("BookmarkedArticle").select().execute().value
            await coreDataManager.saveOrUpdateBookmarkedArticles(bookmarkedArticles)
            debugPrint("Synced \(bookmarkedArticles.count) bookmarks")
        } catch {
            debugPrint("Error syncing BookmarkedArticle: \(error)")
        }
    }
}
