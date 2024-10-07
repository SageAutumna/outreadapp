//
//  FavouriteArticle.swift
//  Outread
//
//  Created by iosware on 27/08/2024.
//

import Foundation

struct FavouriteArticle: Codable, Identifiable {
    let id: String
    let userId: String
    let articleId: String
    let assignedAt: String
    let assignedBy: String
}
