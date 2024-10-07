//
//  DataManager.swift
//  Outread
//
//  Created by iosware on 27/08/2024.
//

import Foundation
import CoreData
import Supabase

class DataManager {
    private let coreDataManager = CoreDataManager.shared

    private let userDefaults = UserDefaults.standard
    private let searchHistoryKey = "searchHistory"
    private let maxSearchHistoryItems = 10
    
    init() {}

    func fetchAllCategories() -> [Category] {
        let fetchRequest: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let categoryMOs = try coreDataManager.context.fetch(fetchRequest)
            return categoryMOs.map { Category(id: $0.id, name: $0.name) }
        } catch {
            debugPrint("Error fetching categories: \(error)")
            return []
        }
    }
    
    func fetchCategory(name: String) -> Category? {
        let fetchRequest: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let categoryMOs = try coreDataManager.context.fetch(fetchRequest)
            if let category = categoryMOs.first {
                return Category(id: category.id, name: category.name)
            } else {
                return nil
            }
        } catch {
            debugPrint("Error fetching categories: \(error)")
            return nil
        }
    }
    
    func fetchAllArticles(page: Int, pageSize: Int) -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = page * pageSize
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let articleMOs = try coreDataManager.context.fetch(fetchRequest)
            return articleMOs.compactMap { DataManager.convertToArticle($0) }
        } catch {
            debugPrint("Error fetching articles: \(error)")
            return []
        }
    }

    func fetchArticlesForCategory(_ categoryId: String, userId: String?, page: Int, pageSize: Int) -> [Article] {
        var articles: [Article] = []
        
        // First, fetch the ArticleToCategoryMO objects for the given category
        let articleToCategoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
        articleToCategoryFetchRequest.predicate = NSPredicate(format: "categoryId == %@", categoryId)
        articleToCategoryFetchRequest.fetchLimit = pageSize
        articleToCategoryFetchRequest.fetchOffset = page * pageSize
        
        do {
            let articleToCategoryMOs = try coreDataManager.context.fetch(articleToCategoryFetchRequest)
            
            // Extract the article IDs
            let articleIds = articleToCategoryMOs.compactMap { $0.articleId }
            
            // Now fetch the actual ArticleMO objects
            let articleFetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
            articleFetchRequest.predicate = NSPredicate(format: "id IN %@", articleIds)
            articleFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let articleMOs = try coreDataManager.context.fetch(articleFetchRequest)
            
            // Fetch all relevant ArticleImageMOs in a single query
            let imageIds = articleMOs.compactMap { $0.imageId }
            let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
            imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
            
            let imageMOs = try coreDataManager.context.fetch(imageFetchRequest)
            
            // Create a dictionary for quick lookup
            let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
            
            articles = articleMOs.compactMap { articleMO -> Article? in
                let articleImage: ArticleImage?
                if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                    articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                } else {
                    articleImage = nil
                }
                
                return self.convertToListArticle(articleMO, image: articleImage)
            }
            for i in articles.indices {
                // Fetch the category IDs for the given article
                let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", articles[i].id)
                
                guard let articleToCategories = try? coreDataManager.context.fetch(categoryFetchRequest),
                      !articleToCategories.isEmpty else {
                    continue
                }
                
                let categoryIds = articleToCategories.compactMap { $0.categoryId }
                if !categoryIds.isEmpty {
                    let categoryFetch: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                    categoryFetch.predicate = NSPredicate(format: "id IN %@", categoryIds)
                    categoryFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                    
                    let categoryMOs = try coreDataManager.context.fetch(categoryFetch)
                    
                    articles[i].tags = categoryMOs.compactMap { $0.name }
                }
            }
            
            // Fetch favorite and bookmarked status
            if let userId = userId?.lowercased() {
                let bookmarkedIds = Set(self.fetchBookmarkedArticleIds(for: userId, articleIds: articleIds, in: coreDataManager.context))
                
                articles = articles.map { article in
                    var mutableArticle = article
                    mutableArticle.isBookmarked = bookmarkedIds.contains(article.id)
                    return mutableArticle
                }
            }
            return articles
        } catch {
            debugPrint("Error fetching articles for category: \(error)")
            return []
        }
    }

    func fetchArticlesForList(listType: ArticleListType, userId: String?, page: Int, pageSize: Int) -> [Article] {
        let context = coreDataManager.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        var articles: [Article] = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
            fetchRequest.fetchLimit = pageSize
            fetchRequest.fetchOffset = page * pageSize
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            switch listType {
            case .all:
                // No additional predicate needed
                break
            case .bookmarked:
                let bookmarkFetch: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
                if let userId = userId {
                    bookmarkFetch.predicate = NSPredicate(format: "userId == %@", userId)
                }
                
                if let articleIds = try? context.fetch(bookmarkFetch).compactMap({ $0.articleId }) {
                    fetchRequest.predicate = NSPredicate(format: "id IN %@", articleIds)
                }
            case .category(let category):
                let articleToCategoryFetch: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                articleToCategoryFetch.predicate = NSPredicate(format: "categoryId == %@", category.id)
                
                if let articleIds = try? context.fetch(articleToCategoryFetch).compactMap({ $0.articleId }) {
                    fetchRequest.predicate = NSPredicate(format: "id IN %@", articleIds)
                }
            case .continueReading:
                let readingFetch: NSFetchRequest<ReadingArticleMO> = ReadingArticleMO.fetch()
                readingFetch.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
                readingFetch.fetchLimit = pageSize
                readingFetch.fetchOffset = page * pageSize
                
                if let articleIds = try? context.fetch(readingFetch).map({ $0.articleId }) {
                    fetchRequest.predicate = NSPredicate(format: "id IN %@", articleIds)
                    fetchRequest.sortDescriptors = [] // Clear existing sort descriptors
                }
            }

            do {
                let articleMOs = try context.fetch(fetchRequest)
                
                // Fetch all relevant ArticleImageMOs in a single query
                let imageIds = articleMOs.compactMap { $0.imageId }
                let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
                imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
                
                let imageMOs = try context.fetch(imageFetchRequest)
                
                // Create a dictionary for quick lookup
                let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
                
                articles = articleMOs.compactMap { articleMO -> Article? in
                    let articleImage: ArticleImage?
                    if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                        articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                    } else {
                        articleImage = nil
                    }
                    
                    return self.convertToListArticle(articleMO, image: articleImage)
                }
                for i in articles.indices {
                    // Fetch the category IDs for the given article
                    let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                    categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", articles[i].id)
                    
                    guard let articleToCategories = try? coreDataManager.context.fetch(categoryFetchRequest),
                          !articleToCategories.isEmpty else {
                        continue
                    }
                    
                    let categoryIds = articleToCategories.compactMap { $0.categoryId }
                    if !categoryIds.isEmpty {
                        let categoryFetch: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                        categoryFetch.predicate = NSPredicate(format: "id IN %@", categoryIds)
                        categoryFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                        
                        let categoryMOs = try coreDataManager.context.fetch(categoryFetch)
                        
                        articles[i].tags = categoryMOs.compactMap { $0.name }
                    }
                }
                
                // Fetch favorite and bookmarked status
                if let userId = userId?.lowercased() {
                    let articleIds = articles.map { $0.id }
                    let bookmarkedIds = Set(self.fetchBookmarkedArticleIds(for: userId, articleIds: articleIds, in: context))
                    
                    articles = articles.map { article in
                        var mutableArticle = article
                        mutableArticle.isBookmarked = bookmarkedIds.contains(article.id)
                        return mutableArticle
                    }
                }
            } catch {
                debugPrint("Error fetching articles: \(error)")
            }
        }

        return articles
    }
    
    func fetchLatestSummaries() -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
        fetchRequest.fetchLimit = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let articleMOs = try coreDataManager.context.fetch(fetchRequest)
            
            // Fetch all relevant ArticleImageMOs in a single query
            let imageIds = articleMOs.compactMap { $0.imageId }
            let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
            imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
            let imageMOs = try coreDataManager.context.fetch(imageFetchRequest)
            
            // Create a dictionary for quick lookup
            let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
            
            var articles = articleMOs.compactMap { articleMO -> Article? in
                let articleImage: ArticleImage?
                if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                    articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                } else {
                    articleImage = nil
                }
                
                return self.convertToListArticle(articleMO, image: articleImage)
            }
            for i in articles.indices {
                // Fetch the category IDs for the given article
                let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", articles[i].id)
                
                guard let articleToCategories = try? coreDataManager.context.fetch(categoryFetchRequest),
                      !articleToCategories.isEmpty else {
                    continue
                }
                
                let categoryIds = articleToCategories.compactMap { $0.categoryId }
                if !categoryIds.isEmpty {
                    let categoryFetch: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                    categoryFetch.predicate = NSPredicate(format: "id IN %@", categoryIds)
                    categoryFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                    
                    let categoryMOs = try coreDataManager.context.fetch(categoryFetch)
                    
                    articles[i].tags = categoryMOs.compactMap { $0.name }
                }
            }
            return articles
        } catch {
            print("Error fetching latest summaries: \(error)")
            return []
        }
    }

    func fetchFeaturedArticles() -> [Article] {
        let context = coreDataManager.context
        
        // First, fetch the most bookmarked articles
        let bookmarkFetchRequest: NSFetchRequest<NSFetchRequestResult> = BookmarkedArticleMO.fetchRequest()
        bookmarkFetchRequest.fetchLimit = 20
        
        // Use an NSDictionaryResultType to get the count of bookmarks for each article
        bookmarkFetchRequest.resultType = .dictionaryResultType
        
        let countExpression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "articleId")])
        let countDescription = NSExpressionDescription()
        countDescription.name = "count"
        countDescription.expression = countExpression
        countDescription.expressionResultType = .integer64AttributeType
        
        bookmarkFetchRequest.propertiesToFetch = ["articleId", countDescription]
        bookmarkFetchRequest.propertiesToGroupBy = ["articleId"]
        bookmarkFetchRequest.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
        
        do {
            let results = try context.fetch(bookmarkFetchRequest)
            let bookmarkResults = results as? [[String: Any]] ?? []
            let featuredArticleIds = bookmarkResults.compactMap { $0["articleId"] as? String }
            
            guard !featuredArticleIds.isEmpty else {
                print("No featured articles found")
                return []
            }
            
            // Now fetch the actual articles
            let articleFetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
            articleFetchRequest.predicate = NSPredicate(format: "id IN %@", featuredArticleIds)
            
            let articleMOs = try context.fetch(articleFetchRequest)
            
            // Fetch all relevant ArticleImageMOs in a single query
            let imageIds = articleMOs.compactMap { $0.imageId }
            let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
            imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
            let imageMOs = try context.fetch(imageFetchRequest)
            
            // Create a dictionary for quick lookup
            let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
            
            // Sort the articles to match the order of featuredArticleIds and convert to Article objects
            var articles = featuredArticleIds.compactMap { id -> Article? in
                guard let articleMO = articleMOs.first(where: { $0.id == id }) else { return nil }
                
                let articleImage: ArticleImage?
                if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                    articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                } else {
                    articleImage = nil
                }
                
                return self.convertToListArticle(articleMO, image: articleImage)
            }
            
            for i in articles.indices {
                // Fetch the category IDs for the given article
                let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", articles[i].id)
                
                guard let articleToCategories = try? context.fetch(categoryFetchRequest),
                      !articleToCategories.isEmpty else {
                    continue
                }
                
                let categoryIds = articleToCategories.compactMap { $0.categoryId }
                if !categoryIds.isEmpty {
                    let categoryFetch: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                    categoryFetch.predicate = NSPredicate(format: "id IN %@", categoryIds)
                    categoryFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                    
                    let categoryMOs = try context.fetch(categoryFetch)
                    
                    articles[i].tags = categoryMOs.compactMap { $0.name }
                }
            }
            return articles
        } catch {
            print("Error fetching featured articles: \(error)")
            return []
        }
    }
    
    private func convertToListArticle(_ articleMO: ArticleMO, image: ArticleImage?) -> Article {
        return Article(
            id: articleMO.id,
            slug: articleMO.slug,
            imageId: articleMO.imageId,
            title: articleMO.title,
            estimatedReadingTime: Int(articleMO.estimatedReadingTime),
            favouritedCount: Int(articleMO.favouritedCount),
            subtitle: articleMO.subtitle,
            createdAt: articleMO.createdAt,
            updatedAt: articleMO.updatedAt,
            altMetricScore: articleMO.altMetricScore,
            doi: articleMO.doi,
            oneCardSummary: Article.Summary(content: [""], heading: ""),
            defaultSummary: [Article.Summary(content: [""], heading: "")],
            simpleSummary: [Article.Summary(content: [""], heading: "")],
            authorName: articleMO.authorName,
            originalPaperTitle: articleMO.originalPaperTitle,
            image: image
        )
    }

    func fetchBookmarkedArticles(for userId: String, page: Int, pageSize: Int) -> [Article] {
        let context = coreDataManager.context
        
        // First, fetch the BookmarkedArticleMO objects
        let bookmarkFetchRequest: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
        bookmarkFetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        bookmarkFetchRequest.fetchLimit = pageSize
        bookmarkFetchRequest.fetchOffset = page * pageSize
        bookmarkFetchRequest.sortDescriptors = [NSSortDescriptor(key: "assignedAt", ascending: false)]
        
        do {
            let bookmarkedArticleMOs = try context.fetch(bookmarkFetchRequest)
            
            // Extract the article IDs
            let articleIds = bookmarkedArticleMOs.compactMap { $0.articleId }
            
            // Fetch the corresponding ArticleMO objects
            let articleFetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
            articleFetchRequest.predicate = NSPredicate(format: "id IN %@", articleIds)
            let articleMOs = try context.fetch(articleFetchRequest)
            
            // Fetch all relevant ArticleImageMOs in a single query
            let imageIds = articleMOs.compactMap { $0.imageId }
            let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
            imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
            let imageMOs = try context.fetch(imageFetchRequest)
            
            // Create a dictionary for quick image lookup
            let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
            
            // Convert ArticleMOs to Articles, including images
            let articles = articleMOs.compactMap { articleMO -> Article? in
                let articleImage: ArticleImage?
                if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                    articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                } else {
                    articleImage = nil
                }
                
                return DataManager.convertToArticle(articleMO, image: articleImage)
            }
            
            // Sort the articles to match the order of bookmarked articles
            var sortedArticles = articleIds.compactMap { id in
                articles.first { $0.id == id }
            }

            for i in sortedArticles.indices {
                // Fetch the category IDs for the given article
                let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", sortedArticles[i].id)
                
                guard let articleToCategories = try? coreDataManager.context.fetch(categoryFetchRequest),
                      !articleToCategories.isEmpty else {
                    continue
                }
                
                let categoryIds = articleToCategories.compactMap { $0.categoryId }
                if !categoryIds.isEmpty {
                    let categoryFetch: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                    categoryFetch.predicate = NSPredicate(format: "id IN %@", categoryIds)
                    categoryFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                    
                    let categoryMOs = try coreDataManager.context.fetch(categoryFetch)
                    
                    sortedArticles[i].tags = categoryMOs.compactMap { $0.name }
                }
            }
            return sortedArticles
        } catch {
            debugPrint("Error fetching bookmarked articles: \(error)")
            return []
        }
    }

    private func fetchBookmarkedArticleIds(for userId: String, articleIds: [String], in context: NSManagedObjectContext) -> [String] {
        let fetchRequest: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "userId == %@ AND articleId IN %@", userId, articleIds)
        
        do {
            let bookmarkedArticles = try context.fetch(fetchRequest)
            return bookmarkedArticles.compactMap { $0.articleId }
        } catch {
            debugPrint("Error fetching bookmarked article IDs: \(error)")
            return []
        }
    }
    
    func fetchBookmarkedArticleIds(for userId: String, articleIds: [String]) -> [String] {
        let fetchRequest: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
        if (!articleIds.isEmpty) {
            fetchRequest.predicate = NSPredicate(format: "userId == %@ AND articleId IN %@", userId, articleIds)
        } else {
            fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        }
        
        do {
            let bookmarkedArticles = try coreDataManager.context.fetch(fetchRequest)
            return bookmarkedArticles.compactMap { $0.articleId }
        } catch {
            debugPrint("Error fetching bookmarked article IDs: \(error)")
            return []
        }
    }

    func fetchRandomArticles(count: Int) -> [Article] {
        let context = coreDataManager.context
        
        // Fetch total count of articles
        let countFetchRequest = NSFetchRequest<NSNumber>(entityName: "ArticleMO")
        countFetchRequest.resultType = .countResultType
        
        do {
            let totalCount = try context.count(for: countFetchRequest)
            guard totalCount > 0 else { return [] }
            
            // Generate random offsets
            var offsets = Set<Int>()
            while offsets.count < min(count, totalCount) {
                offsets.insert(Int.random(in: 0..<totalCount))
            }
            
            // Fetch random articles
            let articleFetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
            articleFetchRequest.fetchLimit = 1
            
            var randomArticleMOs: [ArticleMO] = []
            for offset in offsets {
                articleFetchRequest.fetchOffset = offset
                if let article = try context.fetch(articleFetchRequest).first {
                    randomArticleMOs.append(article)
                }
            }
            
            // Fetch all relevant ArticleImageMOs in a single query
            let imageIds = randomArticleMOs.compactMap { $0.imageId }
            let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
            imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
            let imageMOs = try context.fetch(imageFetchRequest)
            
            // Create a dictionary for quick image lookup
            let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
            
            // Convert ArticleMOs to Articles, including images
            var articles = randomArticleMOs.compactMap { articleMO -> Article? in
                let articleImage: ArticleImage?
                if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                    articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                } else {
                    articleImage = nil
                }
                
                return DataManager.convertToArticle(articleMO, image: articleImage)
            }
            for i in articles.indices {
                // Fetch the category IDs for the given article
                let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", articles[i].id)
                
                guard let articleToCategories = try? coreDataManager.context.fetch(categoryFetchRequest),
                      !articleToCategories.isEmpty else {
                    continue
                }
                
                let categoryIds = articleToCategories.compactMap { $0.categoryId }
                if !categoryIds.isEmpty {
                    let categoryFetch: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                    categoryFetch.predicate = NSPredicate(format: "id IN %@", categoryIds)
                    categoryFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                    
                    let categoryMOs = try coreDataManager.context.fetch(categoryFetch)
                    
                    articles[i].tags = categoryMOs.compactMap { $0.name }
                }
            }
            return articles
        } catch {
            debugPrint("Error fetching random articles: \(error)")
            return []
        }
    }
    
    func fetchArticleWithDetails(id: String, userId: String) -> Article? {
        guard !id.isEmpty else { return nil }
        let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            guard let articleMO = try coreDataManager.context.fetch(fetchRequest).first else {
                return nil
            }
            
            var article: Article?
                        
            if let imageId = articleMO.imageId {
                let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
                imageFetchRequest.predicate = NSPredicate(format: "id == %@", imageId)
                let imageMO = try? coreDataManager.context.fetch(imageFetchRequest).first

                if let imageMO = imageMO {
                    let articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                    article = DataManager.convertToArticle(articleMO, image: articleImage)
                }
            } else {
                article = DataManager.convertToArticle(articleMO)
            }
            
            // Check if bookmarked
            let bookmarkFetchRequest: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
            bookmarkFetchRequest.predicate = NSPredicate(format: "articleId == %@ AND userId == %@", id, userId)
            article?.isBookmarked = (try? coreDataManager.context.count(for: bookmarkFetchRequest)) ?? 0 > 0
            
            // Fetch the category IDs for the given article
            let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
            categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", id)
            
            guard let articleToCategories = try? coreDataManager.context.fetch(categoryFetchRequest),
                  !articleToCategories.isEmpty else {
                return article
            }
            
            let categoryIds = articleToCategories.compactMap { $0.categoryId }
            if !categoryIds.isEmpty {
                article?.categories = categoryIds
                let categoryFetch: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                categoryFetch.predicate = NSPredicate(format: "id IN %@", categoryIds)
                categoryFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                
                let categoryMOs = try coreDataManager.context.fetch(categoryFetch)
                
                article?.tags = categoryMOs.compactMap { $0.name }
            }
            
            return article
        } catch {
            debugPrint("Error fetching article: \(error)")
            return nil
        }
    }
    
    func fetchRelatedArticles(for articleId: String, categoryId: String?, limit: Int = 10) async -> [Article] {
        let context = coreDataManager.context
        
        do {
            return try await context.perform {
                // First, fetch the current article
                let currentArticleFetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
                currentArticleFetchRequest.predicate = NSPredicate(format: "id == %@", articleId)
                
                guard let currentArticleMO = try? context.fetch(currentArticleFetchRequest).first else {
                    return []
                }
                
                var categoryIds: [String] = []
                
                if let categoryId = categoryId, !categoryId.isEmpty {
                    categoryIds = [categoryId]
                } else {
                        // Fetch the category IDs for the given article
                    let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                    categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", articleId)
                    
                    guard let articleToCategories = try? context.fetch(categoryFetchRequest),
                          !articleToCategories.isEmpty else {
                        return [DataManager.convertToArticle(currentArticleMO, image: nil)].compactMap { $0 }
                    }
                    
                    categoryIds = articleToCategories.map { $0.categoryId }
                }
                
                // Now fetch related articles
                let relatedArticlesFetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
                relatedArticlesFetchRequest.predicate = NSPredicate(format: "id != %@ AND ANY articleToCategories.categoryId IN %@", articleId, categoryIds)
                relatedArticlesFetchRequest.fetchLimit = limit - 1  // Fetch one less to make room for the current article
                relatedArticlesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                
                let relatedArticleMOs = try context.fetch(relatedArticlesFetchRequest)
                let allArticleMOs = [currentArticleMO] + relatedArticleMOs
                
                // Fetch all relevant ArticleImageMOs in a single query
                let imageIds = allArticleMOs.compactMap { $0.imageId }
                let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
                imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
                let imageMOs = try context.fetch(imageFetchRequest)
                
                // Create a dictionary for quick image lookup
                let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
                
                // Convert ArticleMOs to Articles, including images
                var articles = allArticleMOs.compactMap { articleMO -> Article? in
                    let articleImage: ArticleImage?
                    if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                        articleImage = ArticleImage(
                            id: imageMO.id,
                            src: imageMO.src,
                            name: imageMO.name,
                            alt: imageMO.alt
                        )
                    } else {
                        articleImage = nil
                    }
                    
                    return DataManager.convertToArticle(articleMO, image: articleImage)
                }
                
                for i in articles.indices {
                    // Fetch the category IDs for the given article
                    let categoryFetchRequest: NSFetchRequest<ArticleToCategoryMO> = ArticleToCategoryMO.fetch()
                    categoryFetchRequest.predicate = NSPredicate(format: "articleId == %@", articles[i].id)
                    
                    guard let articleToCategories = try? context.fetch(categoryFetchRequest),
                          !articleToCategories.isEmpty else {
                        continue
                    }
                    
                    let categoryIds = articleToCategories.compactMap { $0.categoryId }
                    if !categoryIds.isEmpty {
                        let categoryFetch: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                        categoryFetch.predicate = NSPredicate(format: "id IN %@", categoryIds)
                        categoryFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
                        
                        let categoryMOs = try context.fetch(categoryFetch)
                        
                        articles[i].tags = categoryMOs.compactMap { $0.name }
                    }
                }
                return articles
            }
        } catch {
            debugPrint("Error fetching related articles: \(error)")
            return []
        }
    }

    func fetchRelatedAltMetricArticles(for articleId: String, userId: String?, limit: Int = 5) async -> [Article] {
        let context = coreDataManager.context
        
        let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "altMetricScore > %f", 2000.0)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "altMetricScore", ascending: false)]
        fetchRequest.fetchLimit = limit // Limit to top {limit} articles
        
        do {
            let articleMOs = try context.fetch(fetchRequest)
            
            // Fetch all relevant ArticleImageMOs in a single query
            let imageIds = articleMOs.compactMap { $0.imageId }
            let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
            imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
            let imageMOs = try context.fetch(imageFetchRequest)
            
            // Create a dictionary for quick image lookup
            let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
            
            // Fetch bookmarked articles for the user
            var bookmarkedIds: [String] = []
            if let userId = userId {
                let bookmarkFetchRequest: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
                bookmarkFetchRequest.predicate = NSPredicate(format: "userId == %@ AND articleId IN %@", userId, articleMOs.map { $0.id })
                let bookmarkedArticles = try context.fetch(bookmarkFetchRequest)
                let bookmarkedIds = Set(bookmarkedArticles.map { $0.articleId })
            }
      
            // Convert ArticleMOs to Articles, including images and categories
            let articles = articleMOs.compactMap { articleMO -> Article? in
                let articleImage: ArticleImage?
                if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                    articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                } else {
                    articleImage = nil
                }
                
                var article = DataManager.convertToArticle(articleMO, image: articleImage)
                
                // Fetch categories for the article
                if let articleToCategories = articleMO.articleToCategories as? Set<ArticleToCategoryMO> {
                    article?.categories = articleToCategories.compactMap { $0.category.id }
                    article?.tags = articleToCategories.compactMap { $0.category.name }
                }
                
                // Set bookmark status
                article?.isBookmarked = bookmarkedIds.contains(articleMO.id)
                
                return article
            }
            
            return articles
        } catch {
            debugPrint("Error fetching top score articles: \(error)")
            return []
        }
    }

    func toggleBookmark(_ articleId: String, for userId: String) {
        coreDataManager.context.perform {
            if let existingBookmark = self.findBookmark(articleId: articleId, userId: userId) {
                self.coreDataManager.context.delete(existingBookmark)
                Task{
                    do {
                        try await SupabaseManager.shared.client
                            .from("BookmarkedArticle")
                            .delete()
                            .eq("userId", value: userId)
                            .eq("articleId", value: articleId)
                            .execute()
                        debugPrint("Removed supabase bookmark for \(articleId)")
                    } catch {
                        debugPrint("Error deleting bookmarked article \(articleId): \(error)")
                    }
                }
            } else {
                self.addBookmark(articleId: articleId, userId: userId)
                Task {
                    do {
                        let bookmark = BookmarkedArticle(id: UUID().uuidString,
                                                         userId: userId,
                                                         articleId: articleId,
                                                         assignedAt: Date().timestamp,
                                                         assignedBy: userId)
                        try await SupabaseManager.shared.client
                            .from("BookmarkedArticle")
                            .insert(bookmark)
                            .execute()
                        debugPrint("Inserted supabase bookmark for \(articleId)")
                    } catch {
                        debugPrint("Error inserting supabase bookmark: \(error)")
                    }
                }
            }
            do {
                try self.coreDataManager.context.save()
            } catch {
                debugPrint("Error toggling bookmark: \(error)")
            }
        }
    }
    
    func getReading(articleId: String) -> String? {
        return fetchReading(articleId: articleId)
    }

    func updateReading(articleId: String, heading: String) {
        coreDataManager.updateReadingArticleMO(articleId: articleId, heading: heading)
    }

    func getArticlesWithReadingProgress(page: Int, pageSize: Int) -> [Article] {
        return fetchArticlesWithReadingProgress(page: page, pageSize: pageSize)
    }

    func updatePaidUser(userId: String, isPaid: Bool) async throws {
        let role = isPaid ? AppUser.Role.PAID_USER.rawValue : AppUser.Role.USER.rawValue
        try await SupabaseManager.shared.client
            .from("User")
            .update([ "role": "\(role)" ])
            .eq("id", value: userId)
            .execute()
    }
    
    func checkUser(userId: String) async -> Bool {
        do {
            let appUser: AppUser = try await SupabaseManager.shared.client
                .from("User")
                .select()
                .eq("supabaseUserId", value: userId)
                .single()
                .execute()
                .value

            return appUser.role == "PAID_USER"
        } catch {
            debugPrint("error checking user: \(error.localizedDescription)")
            return false
        }
    }
    
// MARK: - Search

    func searchArticles(keyword: String, searchType: SearchType, userId: String?) -> [Article] {
        // Store the search keyword in history
        addToSearchHistory(keyword: keyword)
        
        // Perform the search using CoreDataManager
        var articles = coreDataManager.searchArticles(keyword: keyword, searchType: searchType, userId: userId)
        return articles
    }
    
    func getSearchHistory() -> [String] {
        return userDefaults.stringArray(forKey: searchHistoryKey) ?? []
    }
    
    func addToSearchHistory(keyword: String) {
        var searchHistory = getSearchHistory()
        
        // Remove the keyword if it already exists to avoid duplicates
        searchHistory.removeAll { $0.lowercased() == keyword.lowercased() }
        
        // Add the new keyword at the beginning
        searchHistory.insert(keyword, at: 0)
        
        // Limit the history to maxSearchHistoryItems
        if searchHistory.count > maxSearchHistoryItems {
            searchHistory = Array(searchHistory.prefix(maxSearchHistoryItems))
        }
        
        userDefaults.set(searchHistory, forKey: searchHistoryKey)
    }
    
    func clearSearchHistory() {
        userDefaults.removeObject(forKey: searchHistoryKey)
    }
// MARK: - Private methods
    private func fetchReading(articleId: String) -> String? {
        let fetchRequest: NSFetchRequest<ReadingArticleMO> = ReadingArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "articleId == %@", articleId)
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try self.coreDataManager.context.fetch(fetchRequest)
            return result.first?.heading
        } catch {
            debugPrint("Error fetching reading: \(error)")
            return nil
        }
    }
        
    private func fetchArticlesWithReadingProgress(page: Int, pageSize: Int) -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = page * pageSize
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let articleMOs = try self.coreDataManager.context.fetch(fetchRequest)
            
            // Fetch all relevant ArticleImageMOs and ReadingArticleMOs in single queries
            let articleIds = articleMOs.map { $0.id }
            let imageIds = articleMOs.compactMap { $0.imageId }
            
            let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
            imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
            let imageMOs = try self.coreDataManager.context.fetch(imageFetchRequest)
            
            let readingFetchRequest: NSFetchRequest<ReadingArticleMO> = ReadingArticleMO.fetch()
            readingFetchRequest.predicate = NSPredicate(format: "articleId IN %@", articleIds)
            let readingMOs = try self.coreDataManager.context.fetch(readingFetchRequest)
            
            // Create dictionaries for quick lookup
            let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
            let readingDict = Dictionary(uniqueKeysWithValues: readingMOs.map { ($0.articleId, $0) })
            
            return articleMOs.compactMap { articleMO -> Article? in
                let articleImage: ArticleImage?
                if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                    articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                } else {
                    articleImage = nil
                }
                
                var article = DataManager.convertToArticle(articleMO, image: articleImage)
                if let readingMO = readingDict[articleMO.id] {
                    article?.lastReadSummaryHeading = readingMO.heading
                    article?.lastReadDate = readingMO.updatedAt
                }
                
                return article
            }
        } catch {
            debugPrint("Error fetching articles with reading progress: \(error)")
            return []
        }
    }

    func fetchTopScoreArticles(userId: String?, limit: Int = 5) -> [Article] {
        let context = coreDataManager.context
        
        let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "altMetricScore > %f", 2000.0)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "altMetricScore", ascending: false)]
        fetchRequest.fetchLimit = limit // Limit to top {limit} articles
        
        do {
            let articleMOs = try context.fetch(fetchRequest)
            
            // Fetch all relevant ArticleImageMOs in a single query
            let imageIds = articleMOs.compactMap { $0.imageId }
            let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
            imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
            let imageMOs = try context.fetch(imageFetchRequest)
            
            // Create a dictionary for quick image lookup
            let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
            
            // Fetch bookmarked articles for the user
            var bookmarkedIds: [String] = []
            if let userId = userId {
                let bookmarkFetchRequest: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
                bookmarkFetchRequest.predicate = NSPredicate(format: "userId == %@ AND articleId IN %@", userId, articleMOs.map { $0.id })
                let bookmarkedArticles = try context.fetch(bookmarkFetchRequest)
                let bookmarkedIds = Set(bookmarkedArticles.map { $0.articleId })
            }
      
            // Convert ArticleMOs to Articles, including images and categories
            let articles = articleMOs.compactMap { articleMO -> Article? in
                let articleImage: ArticleImage?
                if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                    articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                } else {
                    articleImage = nil
                }
                
                var article = DataManager.convertToArticle(articleMO, image: articleImage)
                
                // Fetch categories for the article
                if let articleToCategories = articleMO.articleToCategories as? Set<ArticleToCategoryMO> {
                    article?.categories = articleToCategories.compactMap { $0.category.id }
                    article?.tags = articleToCategories.compactMap { $0.category.name }
                }
                
                // Set bookmark status
                article?.isBookmarked = bookmarkedIds.contains(articleMO.id)
                
                return article
            }
            
            return articles
        } catch {
            debugPrint("Error fetching top score articles: \(error)")
            return []
        }
    }
    
    private func findBookmark(articleId: String, userId: String) -> BookmarkedArticleMO? {
        let fetchRequest: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "articleId == %@ AND userId == %@", articleId, userId)
        fetchRequest.fetchLimit = 1
        return try? coreDataManager.context.fetch(fetchRequest).first
    }

    private func addBookmark(articleId: String, userId: String) {
        guard let article = findArticle(id: articleId)
//              let user = findUser(id: userId) 
        else { return }
        let bookmark = BookmarkedArticleMO(context: coreDataManager.context)
        bookmark.id = UUID().uuidString
        bookmark.articleId = articleId
        bookmark.userId = userId
        bookmark.article = article
        bookmark.assignedAt = "\(Date().timestamp)"
        bookmark.assignedBy = userId
    }
    
    private func findArticle(id: String) -> ArticleMO? {
        let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        return try? coreDataManager.context.fetch(fetchRequest).first
    }

    private func findUser(id: String) -> UserMO? {
        let fetchRequest: NSFetchRequest<UserMO> = UserMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        return try? coreDataManager.context.fetch(fetchRequest).first
    }

    static func convertToArticle(_ articleMO: ArticleMO?, image: ArticleImage? = nil) -> Article? {
        guard let articleMO = articleMO else { return nil }
        
        let articleImage: ArticleImage?
        if let imageMO = articleMO.image {
            articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
        } else if let image = image {
            articleImage = image
        } else {
            articleImage = nil
        }
        
        return Article(
            id: articleMO.id,
            slug: articleMO.slug,
            imageId: articleMO.imageId,
            title: articleMO.title,
            estimatedReadingTime: Int(articleMO.estimatedReadingTime),
            favouritedCount: Int(articleMO.favouritedCount),
            subtitle: articleMO.subtitle,
            createdAt: articleMO.createdAt,
            updatedAt: articleMO.updatedAt,
            altMetricScore: articleMO.altMetricScore,
            doi: articleMO.doi,
            oneCardSummary: Article.convertJsonToSummary(articleMO.oneCardSummary) ?? Article.Summary(content: [], heading: ""),
            defaultSummary: Article.convertJsonToSummaryArray(articleMO.defaultSummary) ?? [],
            simpleSummary: Article.convertJsonToSummaryArray(articleMO.simpleSummary) ?? [],
            authorName: articleMO.authorName,
            originalPaperTitle: articleMO.originalPaperTitle,
            image: articleImage
        )
    }
}
