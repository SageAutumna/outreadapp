//
//  Category.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import Foundation

struct Category: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    init(id: String = UUID().uuidString,
         name: String) {
        self.id = id
        self.name = name
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
