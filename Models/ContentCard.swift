//
//  ContentCard.swift
//  Outread
//
//  Created by iosware on 22/08/2024.
//

import Foundation

struct ContentCard: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let imageId: String
    let articleId: String
    let heading: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case id, imageId, articleId, heading, content
    }
    
    init(id: String = UUID().uuidString,
         imageId: String,
         articleId: String,
         heading: String,
         content: String) {
        self.id = id
        self.imageId = imageId
        self.articleId = articleId
        self.heading = heading
        self.content = content
    }
    
    static func == (lhs: ContentCard, rhs: ContentCard) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
