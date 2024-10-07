//
//  ArticleImage.swift
//  Outread
//
//  Created by iosware on 22/08/2024.
//

import Foundation

struct ArticleImage: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let src: String
    let name: String
    let alt: String
    
    enum CodingKeys: String, CodingKey {
        case id, src, name, alt
    }
    
    init(id: String = UUID().uuidString,
         src: String,
         name: String,
         alt: String) {
        self.id = id
        self.src = src
        self.name = name
        self.alt = alt
    }
    
    static func == (lhs: ArticleImage, rhs: ArticleImage) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
