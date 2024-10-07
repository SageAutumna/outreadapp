//
//  ManagedObjects.swift
//  Outread
//
//  Created by iosware on 28/08/2024.
//

import Foundation
import CoreData

@objc(CategoryMO)
public class CategoryMO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var articleToCategories: NSSet?
}

@objc(ArticleMO)
public class ArticleMO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var slug: String
    @NSManaged public var imageId: String?
    @NSManaged public var title: String
    @NSManaged public var estimatedReadingTime: Int32
    @NSManaged public var favouritedCount: Int32
    @NSManaged public var subtitle: String
    @NSManaged public var createdAt: String
    @NSManaged public var updatedAt: String
    @NSManaged public var altMetricScore: Double
    @NSManaged public var doi: String
    @NSManaged public var oneCardSummary: String?
    @NSManaged public var defaultSummary: String?
    @NSManaged public var simpleSummary: String?
    @NSManaged public var authorName: String
    @NSManaged public var originalPaperTitle: String
    @NSManaged public var lastReadSummaryHeading: String?
    @NSManaged public var lastReadDate: Date?
    
    @NSManaged public var image: ArticleImageMO?
    @NSManaged public var articleToCategories: NSSet?
    @NSManaged public var bookmarks: NSSet?
    @NSManaged public var favorites: NSSet?
}

@objc(ArticleToCategoryMO)
public class ArticleToCategoryMO: NSManagedObject {
    @NSManaged public var articleId: String
    @NSManaged public var categoryId: String
    @NSManaged public var article: ArticleMO
    @NSManaged public var category: CategoryMO
}

@objc(ArticleImageMO)
public class ArticleImageMO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var src: String
    @NSManaged public var name: String
    @NSManaged public var alt: String
    @NSManaged public var article: ArticleMO?
}

@objc(UserMO)
public class UserMO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var username: String?
    @NSManaged public var passwordHash: String
    @NSManaged public var profilePictureSrc: String?
    @NSManaged public var email: String
    @NSManaged public var role: String
    @NSManaged public var createdAt: String
    @NSManaged public var updatedAt: String
    @NSManaged public var sessions: NSSet?
    @NSManaged public var comments: NSSet?
    @NSManaged public var favouriteArticles: NSSet?
    @NSManaged public var bookmarkedArticles: NSSet?
}

@objc(CommentMO)
public class CommentMO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var articleId: String
    @NSManaged public var userId: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: String
    @NSManaged public var updatedAt: String
    @NSManaged public var article: ArticleMO?
//    @NSManaged public var user: UserMO?
}

@objc(BookmarkedArticleMO)
public class BookmarkedArticleMO: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var articleId: String
    @NSManaged public var assignedAt: String
    @NSManaged public var assignedBy: String?   
//    @NSManaged public var user: UserMO?
    @NSManaged public var article: ArticleMO?
}

@objc(ReadingArticleMO)
public class ReadingArticleMO: NSManagedObject {
    @NSManaged public var articleId: String
    @NSManaged public var heading: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}


extension CategoryMO {
    @nonobjc public class func fetch() -> NSFetchRequest<CategoryMO> {
        return NSFetchRequest<CategoryMO>(entityName: "CategoryMO")
    }
}
extension CategoryMO {
    @objc(addArticleToCategoriesObject:)
    @NSManaged public func addToCategoryToArticles(_ value: ArticleToCategoryMO)

    @objc(removeArticleToCategoriesObject:)
    @NSManaged public func removeFromCategoryToArticles(_ value: ArticleToCategoryMO)

    @objc(addArticleToCategories:)
    @NSManaged public func addToCategoryToArticles(_ values: NSSet)

    @objc(removeArticleToCategories:)
    @NSManaged public func removeFromCategoryToArticles(_ values: NSSet)

}


extension ArticleMO {
    @nonobjc public class func fetch() -> NSFetchRequest<ArticleMO> {
        return NSFetchRequest<ArticleMO>(entityName: "ArticleMO")
    }
}

extension ArticleMO {
    @objc(addArticleToCategoriesObject:)
    @NSManaged public func addToArticleToCategories(_ value: ArticleToCategoryMO)

    @objc(removeArticleToCategoriesObject:)
    @NSManaged public func removeFromArticleToCategories(_ value: ArticleToCategoryMO)

    @objc(addArticleToCategories:)
    @NSManaged public func addToArticleToCategories(_ values: NSSet)

    @objc(removeArticleToCategories:)
    @NSManaged public func removeFromArticleToCategories(_ values: NSSet)
}

extension ArticleMO {
    @objc(addBookmarksObject:)
    @NSManaged public func addToBookmarks(_ value: BookmarkedArticleMO)

    @objc(removeBookmarksObject:)
    @NSManaged public func removeFromBookmarks(_ value: BookmarkedArticleMO)

    @objc(addBookmarks:)
    @NSManaged public func addToBookmarks(_ values: NSSet)

    @objc(removeBookmarks:)
    @NSManaged public func removeFromBookmarks(_ values: NSSet)
}

extension ArticleToCategoryMO {
    @nonobjc public class func fetch() -> NSFetchRequest<ArticleToCategoryMO> {
        return NSFetchRequest<ArticleToCategoryMO>(entityName: "ArticleToCategoryMO")
    }
}
extension ArticleImageMO {
    @nonobjc public class func fetch() -> NSFetchRequest<ArticleImageMO> {
        return NSFetchRequest<ArticleImageMO>(entityName: "ArticleImageMO")
    }
}

extension UserMO {
    @nonobjc public class func fetch() -> NSFetchRequest<UserMO> {
        return NSFetchRequest<UserMO>(entityName: "UserMO")
    }
}

extension CommentMO {
    @nonobjc public class func fetch() -> NSFetchRequest<CommentMO> {
        return NSFetchRequest<CommentMO>(entityName: "CommentMO")
    }
}

extension BookmarkedArticleMO {
    @nonobjc public class func fetch() -> NSFetchRequest<BookmarkedArticleMO> {
        return NSFetchRequest<BookmarkedArticleMO>(entityName: "BookmarkedArticleMO")
    }
}

extension ReadingArticleMO {
    @nonobjc public class func fetch() -> NSFetchRequest<ReadingArticleMO> {
        return NSFetchRequest<ReadingArticleMO>(entityName: "ReadingArticleMO")
    }
}
