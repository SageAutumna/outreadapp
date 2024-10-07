//
//  TempData.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import Foundation

class TempData {
    static let shared = TempData()
    
    let categories: [Category] = [
        Category(id: "1", name: "Business"),
        Category(id: "2", name: "Psychology"),
        Category(id: "3", name: "Astronomy"),
        Category(id: "4", name: "Comedy"),
        Category(id: "5", name: "Economics"),
        Category(id: "6", name: "Energy"),
        Category(id: "7", name: "Environment"),
        Category(id: "8", name: "Health"),
        Category(id: "9", name: "History"),
        Category(id: "10", name: "Mathematics"),
        Category(id: "11", name: "Medicine"),
        Category(id: "12", name: "Philosophy"),
        Category(id: "13", name: "Physics"),
        Category(id: "14", name: "Politics"),
        Category(id: "15", name: "Psychology"),
        Category(id: "16", name: "Science"),
        Category(id: "17", name: "Sociology"),
        Category(id: "18", name: "Technology"),
        Category(id: "19", name: "Travel"),
        Category(id: "20", name: "Weather")
    ]
    
    let articles: [Article] = Article.generateRandomArticles(count: 20)

    func summaryArticles() -> [Article] {
        return getUniqueRandomElements(6)
    }
    
    func featuredArticles() -> [Article] {
        return getUniqueRandomElements(5)
    }
    
    func shortDescriptionArticles() -> [Article] {
        return getUniqueRandomElements(6)
    }
    
    func psychologyArticles() -> [Article] {
        return getUniqueRandomElements(8)
    }
    func healthArticles() -> [Article] {
        return getUniqueRandomElements(8)
    }
    
    func getUniqueRandomElements(_ number: Int) -> [Article] {
        let articles = TempData.shared.articles.shuffled()
        var uniqueArticles = Set<Article>()

        for article in articles {
            uniqueArticles.insert(article)
            if uniqueArticles.count == number {
                break
            }
        }

        return Array(uniqueArticles)
    }
}
