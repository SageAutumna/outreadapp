//
//  CoreDataManager.swift
//  Outread
//
//  Created by iosware on 27/08/2024.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Outread")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Generic save or update function
    func saveOrUpdate<T: NSManagedObject, U: Identifiable>(
        _ objects: [U],
        fetchRequest: NSFetchRequest<T>,
        idKeyPath: KeyPath<U, String>,
        updateBlock: @escaping (T, U) -> Void
    ) {
        let context = persistentContainer.newBackgroundContext()
        context.performAndWait {
            for object in objects {
                fetchRequest.predicate = NSPredicate(format: "id == %@", object[keyPath: idKeyPath])
                
                do {
                    let results = try context.fetch(fetchRequest)
                    let managedObject: T
                    if let existingObject = results.first {
                        managedObject = existingObject
                    } else {
                        managedObject = T(context: context)
                    }
                    updateBlock(managedObject, object)
                } catch {
                    debugPrint("Error fetching or creating object: \(error)")
                }
            }
            
            do {
                try context.save()
            } catch {
                debugPrint("Error saving context: \(error)")
            }
        }
    }
}

// MARK: - Save or update functions for specific entities
extension CoreDataManager {
    func saveOrUpdateCategories(_ categories: [Category]) async {
        await MainActor.run {
            saveOrUpdate(categories, fetchRequest: CategoryMO.fetch(), idKeyPath: \Category.id) { (managedObject: CategoryMO, category: Category) in
                managedObject.id = category.id
                managedObject.name = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    
    func cleanArticleToCategoryTable() async {
        let context = persistentContainer.newBackgroundContext()
        
        await context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ArticleToCategoryMO.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
                try context.save()
            } catch {
                debugPrint("Error cleaning ArticleToCategoryMO table: \(error)")
            }
        }
    }
    
    func saveOrUpdateArticles(_ articles: [Article]) async {
        await MainActor.run {
            let context = persistentContainer.newBackgroundContext()
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            context.performAndWait {
                let batchSize = 500
                let batches = stride(from: 0, to: articles.count, by: batchSize).map {
                    Array(articles[$0..<min($0 + batchSize, articles.count)])
                }
                
                for batch in batches {
                    autoreleasepool {
                        for article in batch {
                            let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
                            fetchRequest.predicate = NSPredicate(format: "id == %@", article.id)
                            fetchRequest.fetchLimit = 1
                            
                            do {
                                let results = try context.fetch(fetchRequest)
                                let articleMO: ArticleMO
                                if let existingArticle = results.first {
                                    articleMO = existingArticle
                                } else {
                                    articleMO = ArticleMO(context: context)
                                }
                                
                                self.updateArticleMO(articleMO, with: article, in: context)
                            } catch {
                                debugPrint("Error fetching or creating Article object: \(error)")
                            }
                        }
                        
                        do {
                            try context.save()
                            context.reset()
                        } catch {
                            debugPrint("Error saving batch: \(error)")
                            context.rollback()
                        }
                    }
                }
            }
        }
    }

    private func updateArticleMO(_ articleMO: ArticleMO, with article: Article, in context: NSManagedObjectContext) {
        articleMO.id = article.id
        articleMO.slug = article.slug
        articleMO.imageId = article.imageId
        articleMO.title = article.title
        articleMO.estimatedReadingTime = Int32(article.estimatedReadingTime)
        articleMO.favouritedCount = Int32(article.favouritedCount)
        articleMO.subtitle = article.subtitle
        articleMO.createdAt = article.createdAt
        articleMO.updatedAt = article.updatedAt
        articleMO.altMetricScore = article.altMetricScore
        articleMO.doi = article.doi
        articleMO.authorName = article.authorName
        articleMO.originalPaperTitle = article.originalPaperTitle
        
        // Convert and store JSON string fields
        articleMO.oneCardSummary = convertSummaryToJson(article.oneCardSummary)
        articleMO.defaultSummary = convertSummaryArrayToJson(article.defaultSummary)
        articleMO.simpleSummary = convertSummaryArrayToJson(article.simpleSummary)
        
        // Handle ArticleImage
        if let articleImage = article.image {
            let imageMO = articleMO.image ?? ArticleImageMO(context: context)
            imageMO.id = articleImage.id
            imageMO.src = articleImage.src
            imageMO.name = articleImage.name
            imageMO.alt = articleImage.alt
            articleMO.image = imageMO
        } else {
            if let existingImage = articleMO.image {
                context.delete(existingImage)
            }
            articleMO.image = nil
        }
        
        // Handle categories
        if let categories = article.categories {
            // Remove old relationships
            if let existingRelationships = articleMO.articleToCategories as? Set<ArticleToCategoryMO> {
                for relationship in existingRelationships {
                    context.delete(relationship)
                }
            }
            
            // Create new relationships
            for categoryId in categories {
                let articleToCategory = ArticleToCategoryMO(context: context)
                articleToCategory.articleId = article.id
                articleToCategory.categoryId = categoryId
                articleToCategory.article = articleMO
                
                // Fetch or create CategoryMO
                let categoryFetchRequest: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                categoryFetchRequest.predicate = NSPredicate(format: "id == %@", categoryId)
                let categoryResults = try? context.fetch(categoryFetchRequest)
                let categoryMO: CategoryMO
                if let existingCategory = categoryResults?.first {
                    categoryMO = existingCategory
                } else {
                    categoryMO = CategoryMO(context: context)
                    categoryMO.id = categoryId
                    categoryMO.name = "Category \(categoryId)" // You might want to fetch the actual name from somewhere
                }
                
                articleToCategory.category = categoryMO
                articleMO.addToArticleToCategories(articleToCategory)
                categoryMO.addToCategoryToArticles(articleToCategory)
            }
        } else {
            // If no categories provided, remove all existing relationships
            if let existingRelationships = articleMO.articleToCategories as? Set<ArticleToCategoryMO> {
                for relationship in existingRelationships {
                    context.delete(relationship)
                }
            }
            articleMO.articleToCategories = nil
        }
    }
    
    func saveOrUpdateArticleToCategories(_ relationships: [(String, String)]) async {
        await MainActor.run {
            let context = persistentContainer.newBackgroundContext()
            context.performAndWait {
                for (articleId, categoryId) in relationships {
                    let newRelationship = ArticleToCategoryMO(context: context)
                    newRelationship.articleId = articleId
                    newRelationship.categoryId = categoryId
                    
                    // Set up the relationships if the entities exist
                    if let article = try? fetchArticle(with: articleId, in: context) {
                        newRelationship.article = article
                    }
                    if let category = try? fetchCategory(with: categoryId, in: context) {
                        newRelationship.category = category
                    }
                }
                
                do {
                    try context.save()
                } catch {
                    debugPrint("Error saving ArticleToCategory relationships: \(error)")
                    context.rollback()
                }
            }
        }
    }
    
    private func fetchArticle(with id: String, in context: NSManagedObjectContext) throws -> ArticleMO? {
        let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(fetchRequest).first
    }
    
    private func fetchCategory(with id: String, in context: NSManagedObjectContext) throws -> CategoryMO? {
        let fetchRequest: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(fetchRequest).first
    }
    
    private func updateArticleMO(_ articleMO: ArticleMO, with article: Article) {
        articleMO.id = article.id
        articleMO.slug = article.slug
        articleMO.imageId = article.imageId
        articleMO.title = article.title
        articleMO.estimatedReadingTime = Int32(article.estimatedReadingTime)
        articleMO.favouritedCount = Int32(article.favouritedCount)
        articleMO.subtitle = article.subtitle
        articleMO.createdAt = article.createdAt
        articleMO.updatedAt = article.updatedAt
        articleMO.altMetricScore = article.altMetricScore
        articleMO.doi = article.doi
        articleMO.authorName = article.authorName
        articleMO.originalPaperTitle = article.originalPaperTitle
        
        // Convert and store JSON string fields
        articleMO.oneCardSummary = convertSummaryToJson(article.oneCardSummary)
        articleMO.defaultSummary = convertSummaryArrayToJson(article.defaultSummary)
        articleMO.simpleSummary = convertSummaryArrayToJson(article.simpleSummary)
        
        // Handle ArticleImage
        if let articleImage = article.image {
            let imageMO = articleMO.image ?? ArticleImageMO(context: articleMO.managedObjectContext!)
            imageMO.id = articleImage.id
            imageMO.src = articleImage.src
            imageMO.name = articleImage.name
            imageMO.alt = articleImage.alt
            articleMO.image = imageMO
        } else {
            articleMO.image = nil
        }
        
        // Handle categories
        if let categories = article.categories {
            // Remove old relationships
            if let existingRelationships = articleMO.articleToCategories as? Set<ArticleToCategoryMO> {
                for relationship in existingRelationships {
                    context.delete(relationship)
                }
            }
            
            // Create new relationships
            for categoryId in categories {
                let articleToCategory = ArticleToCategoryMO(context: context)
                articleToCategory.articleId = article.id
                articleToCategory.categoryId = categoryId
                articleToCategory.article = articleMO
                
                // Fetch or create CategoryMO
                let categoryFetchRequest: NSFetchRequest<CategoryMO> = CategoryMO.fetch()
                categoryFetchRequest.predicate = NSPredicate(format: "id == %@", categoryId)
                let categoryResults = try? context.fetch(categoryFetchRequest)
                let categoryMO: CategoryMO
                if let existingCategory = categoryResults?.first {
                    categoryMO = existingCategory
                } else {
                    categoryMO = CategoryMO(context: context)
                    categoryMO.id = categoryId
                    categoryMO.name = "Category \(categoryId)" // You might want to fetch the actual name from somewhere
                }
                
                articleToCategory.category = categoryMO
                articleMO.addToArticleToCategories(articleToCategory)
                categoryMO.addToCategoryToArticles(articleToCategory)
            }
        } else {
            // If no categories provided, remove all existing relationships
            if let existingRelationships = articleMO.articleToCategories as? Set<ArticleToCategoryMO> {
                for relationship in existingRelationships {
                    context.delete(relationship)
                }
            }
            articleMO.articleToCategories = nil
        }
    }

    func updateReadingArticleMO(articleId: String, heading: String) {
        let fetchRequest: NSFetchRequest<ReadingArticleMO> = ReadingArticleMO.fetch()
        fetchRequest.predicate = NSPredicate(format: "articleId == %@", articleId)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            let reading: ReadingArticleMO
            
            if let existingReading = results.first {
                reading = existingReading
                reading.updatedAt = Date()
            } else {
                reading = ReadingArticleMO(context: context)
                reading.articleId = articleId
                reading.createdAt = Date()
                reading.updatedAt = Date()
            }
            
            reading.heading = heading
            
            try context.save()
        } catch {
            debugPrint("Error updating reading: \(error)")
        }
    }
    
    func saveOrUpdateArticleImages(_ articleImages: [ArticleImage]) async {
        await MainActor.run {
            saveOrUpdate(articleImages, fetchRequest: ArticleImageMO.fetch(), idKeyPath: \ArticleImage.id) { (managedObject: ArticleImageMO, articleImage: ArticleImage) in
                managedObject.id = articleImage.id
                managedObject.src = articleImage.src
                managedObject.name = articleImage.name
                managedObject.alt = articleImage.alt
            }
        }
    }
        
    func saveOrUpdateComments(_ comments: [Comment]) async {
        await MainActor.run {
            saveOrUpdate(comments, fetchRequest: CommentMO.fetch(), idKeyPath: \Comment.id) { (managedObject: CommentMO, comment: Comment) in
                managedObject.id = comment.id
                managedObject.articleId = comment.articleId
                managedObject.userId = comment.userId
                managedObject.content = comment.content
                managedObject.createdAt = comment.createdAt
                managedObject.updatedAt = comment.updatedAt
                // Assume we've already saved the article and user
                managedObject.article = try? self.context.fetch(ArticleMO.fetch()).first(where: { $0.id == comment.articleId })
//                managedObject.user = try? self.context.fetch(UserMO.fetch()).first(where: { $0.id == comment.userId })
            }
        }
    }
    
    func saveOrUpdateBookmarkedArticles(_ bookmarkedArticles: [BookmarkedArticle]) async {
        await MainActor.run {
            saveOrUpdate(bookmarkedArticles, fetchRequest: BookmarkedArticleMO.fetch(), idKeyPath: \BookmarkedArticle.id) { (managedObject: BookmarkedArticleMO, bookmarkedArticle: BookmarkedArticle) in
                managedObject.id = bookmarkedArticle.id
                managedObject.userId = bookmarkedArticle.userId
                managedObject.articleId = bookmarkedArticle.articleId
                managedObject.assignedAt = bookmarkedArticle.assignedAt
                managedObject.assignedBy = bookmarkedArticle.assignedBy
            }
        }
    }
    
    func searchArticles(keyword: String, searchType: SearchType, userId: String? = nil) -> [Article] {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        var articles: [Article] = []
        
        context.performAndWait {
                let fetchRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetch()
                
                var predicate: NSPredicate
                switch searchType {
                case .recent:
                    let readingFetch: NSFetchRequest<ReadingArticleMO> = ReadingArticleMO.fetch()
                    readingFetch.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
                    if let recentArticleIds = try? context.fetch(readingFetch).map({ $0.articleId }) {
                        predicate = NSPredicate(format: "id IN %@ AND (title CONTAINS[cd] %@ OR subtitle CONTAINS[cd] %@ OR authorName CONTAINS[cd] %@ OR oneCardSummary CONTAINS[cd] %@)", recentArticleIds, keyword, keyword, keyword, keyword)
                    } else {
                        return
                    }
                case .popular:
                    let bookmarkFetch: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
                    if let popularArticleIds = try? context.fetch(bookmarkFetch).map({ $0.articleId }) {
                        predicate = NSPredicate(format: "id IN %@ AND (title CONTAINS[cd] %@ OR subtitle CONTAINS[cd] %@ OR authorName CONTAINS[cd] %@ OR oneCardSummary CONTAINS[cd] %@)", popularArticleIds, keyword, keyword, keyword, keyword)
                    } else {
                        return
                    }
                case .bestMatches:
                    predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR subtitle CONTAINS[cd] %@ OR authorName CONTAINS[cd] %@ OR oneCardSummary CONTAINS[cd] %@", keyword, keyword, keyword, keyword)
                }
                
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                
                // Fetch articles in batches
                fetchRequest.fetchBatchSize = 20
                
                do {
                    let articleMOs = try context.fetch(fetchRequest)
                    
                    // Process articles in batches
                    let batchSize = 20
                    for startIndex in stride(from: 0, to: articleMOs.count, by: batchSize) {
                        let endIndex = min(startIndex + batchSize, articleMOs.count)
                        let batch = Array(articleMOs[startIndex..<endIndex])
                        
                        let imageIds = batch.compactMap { $0.imageId }
                        let imageFetchRequest: NSFetchRequest<ArticleImageMO> = ArticleImageMO.fetch()
                        imageFetchRequest.predicate = NSPredicate(format: "id IN %@", imageIds)
                        let imageMOs = try context.fetch(imageFetchRequest)
                        
                        let imageDict = Dictionary(uniqueKeysWithValues: imageMOs.map { ($0.id, $0) })
                        
                        let batchArticles = batch.compactMap { articleMO -> Article? in
                            let articleImage: ArticleImage?
                            if let imageId = articleMO.imageId, let imageMO = imageDict[imageId] {
                                articleImage = ArticleImage(id: imageMO.id, src: imageMO.src, name: imageMO.name, alt: imageMO.alt)
                            } else {
                                articleImage = nil
                            }
                            
                            return DataManager.convertToArticle(articleMO, image: articleImage)
                        }
                        
                        articles.append(contentsOf: batchArticles)
                        
                        // Clear the context to free up memory
                        context.reset()
                    }
                    
                    // Check bookmarks in a separate batch
                    if let userId = userId {
                        let bookmarkFetchRequest: NSFetchRequest<BookmarkedArticleMO> = BookmarkedArticleMO.fetch()
                        bookmarkFetchRequest.predicate = NSPredicate(format: "userId == %@ AND articleId IN %@", userId, articles.map { $0.id })
                        let bookmarkedArticles = try context.fetch(bookmarkFetchRequest)
                        let bookmarkedIds = Set(bookmarkedArticles.map { $0.articleId })
                        
                        for i in articles.indices {
                            articles[i].isBookmarked = bookmarkedIds.contains(articles[i].id)
                        }
                    }
                } catch {
                    debugPrint("Error searching articles: \(error)")
                }
            }
            
            return articles
    }
}
