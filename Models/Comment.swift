//
//  Comment.swift
//  Outread
//
//  Created by iosware on 28/08/2024.
//

import Foundation

struct Comment: Codable, Identifiable {
    let id: String
    let articleId: String
    let userId: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let article: Article?
}
