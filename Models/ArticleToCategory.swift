//
//  ArticleToCategory.swift
//  Outread
//
//  Created by iosware on 27/08/2024.
//

import Foundation

struct ArticleToCategory: Codable, Equatable, Hashable {
    let articleId: String
    let categoryId: String
    let article: Article?
    let category: Category?
    
    static func == (lhs: ArticleToCategory, rhs: ArticleToCategory) -> Bool {
        lhs.articleId == rhs.articleId && lhs.categoryId == rhs.categoryId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(articleId)-\(categoryId)")
    }
}
