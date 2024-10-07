//
//  Article.swift
//  Outread
//
//  Created by iosware on 20/08/2024.
//

import Foundation

struct Article: Codable, Identifiable, Hashable {
    struct Summary: Codable, Equatable, Hashable {
        let content: [String]
        let heading: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let summaryString = try? container.decode(String.self) {
//                deubgPrint("Debug - Summary is a string: \(summaryString)")
                heading = ""
                content = [summaryString]
            } else {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
//                deubgPrint("Debug - Raw content for Summary: \(try container.decode(AnyCodable.self, forKey: .content))")
                
                if let headingString = try? container.decode(String.self, forKey: .heading) {
                    heading = headingString
                } else {
                    heading = ""
                }
                            
                // Handle content as either String or [String]
                if let contentString = try? container.decode(String.self, forKey: .content) {
                    content = [contentString]
                } else if let contentArray = try? container.decode([String].self, forKey: .content) {
                    content = contentArray
                } else {
                    content = [""]
                }
            }
//            deubgPrint("Debug - Decoded Summary: heading='\(heading ?? "")', content=\(content)")
        }
        
        init(content: [String], heading: String?) {
            self.content = content
            self.heading = heading
        }
        
        static func == (lhs: Summary, rhs: Summary) -> Bool {
            lhs.content == rhs.content && lhs.heading == rhs.heading
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(content)
//            hasher.combine(heading)
        }
    }

    let id: String
    let slug: String
    let imageId: String?
    let title: String
    let estimatedReadingTime: Int
    let favouritedCount: Int
    let subtitle: String
    let createdAt: String
    let updatedAt: String
    let altMetricScore: Double
    let doi: String
    let oneCardSummary: Summary
    let defaultSummary: [Summary]
    let simpleSummary: [Summary]
    let authorName: String
    let originalPaperTitle: String
    let image: ArticleImage?
    var categories: [String]?

    // These properties are not stored directly in CoreData
    // They are computed based on relationships or other data
    var isBookmarked: Bool = false
    var lastReadSummaryHeading: String?
    var lastReadDate: Date?
    
    var tags: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, slug, imageId, title, estimatedReadingTime, favouritedCount, subtitle, createdAt, updatedAt, altMetricScore, doi, oneCardSummary, defaultSummary, simpleSummary, authorName, originalPaperTitle, image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        slug = try container.decode(String.self, forKey: .slug)
        imageId = try container.decodeIfPresent(String.self, forKey: .imageId)
        title = try container.decode(String.self, forKey: .title)
        estimatedReadingTime = try container.decode(Int.self, forKey: .estimatedReadingTime)
        favouritedCount = try container.decode(Int.self, forKey: .favouritedCount)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        altMetricScore = try container.decode(Double.self, forKey: .altMetricScore)
        doi = try container.decode(String.self, forKey: .doi)
        authorName = try container.decode(String.self, forKey: .authorName)
        originalPaperTitle = try container.decode(String.self, forKey: .originalPaperTitle)
        image = try container.decodeIfPresent(ArticleImage.self, forKey: .image)

//        deubgPrint("Debug - Raw simpleSummary: \(try container.decode(AnyCodable.self, forKey: .simpleSummary))")
        
        // Decode JSON objects/arrays directly
        oneCardSummary = try container.decode(Summary.self, forKey: .oneCardSummary)
        defaultSummary = try container.decode([Summary].self, forKey: .defaultSummary)
        simpleSummary = try container.decode([Summary].self, forKey: .simpleSummary)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(slug, forKey: .slug)
        try container.encodeIfPresent(imageId, forKey: .imageId)
        try container.encode(title, forKey: .title)
        try container.encode(estimatedReadingTime, forKey: .estimatedReadingTime)
        try container.encode(favouritedCount, forKey: .favouritedCount)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(altMetricScore, forKey: .altMetricScore)
        try container.encode(doi, forKey: .doi)
        try container.encode(authorName, forKey: .authorName)
        try container.encode(originalPaperTitle, forKey: .originalPaperTitle)
        try container.encodeIfPresent(image, forKey: .image)

        try container.encode(oneCardSummary, forKey: .oneCardSummary)
        try container.encode(defaultSummary, forKey: .defaultSummary)
        try container.encode(simpleSummary, forKey: .simpleSummary)
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension Article {
    init(id: String, slug: String, imageId: String?, title: String, estimatedReadingTime: Int, favouritedCount: Int, subtitle: String, createdAt: String, updatedAt: String, altMetricScore: Double, doi: String, oneCardSummary: Summary, defaultSummary: [Summary], simpleSummary: [Summary], authorName: String, originalPaperTitle: String, image: ArticleImage?) {
        self.id = id
        self.slug = slug
        self.imageId = imageId
        self.title = title
        self.estimatedReadingTime = estimatedReadingTime
        self.favouritedCount = favouritedCount
        self.subtitle = subtitle
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.altMetricScore = altMetricScore
        self.doi = doi
        self.oneCardSummary = oneCardSummary
        self.defaultSummary = defaultSummary
        self.simpleSummary = simpleSummary
        self.authorName = authorName
        self.originalPaperTitle = originalPaperTitle
        self.image = image
    }
    
    static func convertJsonToSummary(_ json: String?) -> Article.Summary? {
        guard let json = json, let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Article.Summary.self, from: data)
        } catch {
            print("Error decoding Summary: \(error)")
            return nil
        }
    }
    
    static func convertJsonToSummaryArray(_ json: String?) -> [Article.Summary]? {
        guard let json = json, let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([Article.Summary].self, from: data)
        } catch {
            print("Error decoding Summary array: \(error)")
            return nil
        }
    }
    
    static func generateRandomArticles(count: Int) -> [Article] {
        let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        
        func randomString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in letters.randomElement()! })
        }
        
        func randomDate() -> String {
            let date = Date(timeIntervalSinceNow: TimeInterval.random(in: -31536000...0))
            let formatter = ISO8601DateFormatter()
            return formatter.string(from: date)
        }
        
        func randomSummary() -> Article.Summary {
            return Article.Summary(
                content: [String(loremIpsum.prefix(Int.random(in: 50...200)))],
                heading: "Heading \(randomString(length: 5))"
            )
        }
        
        return (0..<count).map { _ in
            Article(
                id: UUID().uuidString,
                slug: randomString(length: 10),
                imageId: Bool.random() ? UUID().uuidString : nil,
                title: "Article \(randomString(length: 8))",
                estimatedReadingTime: Int.random(in: 1...30),
                favouritedCount: Int.random(in: 0...1000),
                subtitle: String(loremIpsum.prefix(Int.random(in: 20...100))),
                createdAt: randomDate(),
                updatedAt: randomDate(),
                altMetricScore: Double.random(in: 0...100),
                doi: "10.\(Int.random(in: 1000...9999))/\(randomString(length: 8))",
                oneCardSummary: randomSummary(),
                defaultSummary: (0..<Int.random(in: 1...5)).map { _ in randomSummary() },
                simpleSummary: (0..<Int.random(in: 1...3)).map { _ in randomSummary() },
                authorName: "Author \(randomString(length: 6))",
                originalPaperTitle: "Original Paper \(randomString(length: 10))",
                image: ArticleImage(id: UUID().uuidString,
                                    src: "https://picsum.photos/300/400",
                                    name: "Image \(randomString(length: 5))",
                                    alt: "Image \(randomString(length: 5))")
            )
        }
    }
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            value = x
        } else if let x = try? container.decode(Int.self) {
            value = x
        } else if let x = try? container.decode(Double.self) {
            value = x
        } else if let x = try? container.decode(String.self) {
            value = x
        } else if let x = try? container.decode([AnyCodable].self) {
            value = x.map { $0.value }
        } else if let x = try? container.decode([String: AnyCodable].self) {
            value = x.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let x as Bool:
            try container.encode(x)
        case let x as Int:
            try container.encode(x)
        case let x as Double:
            try container.encode(x)
        case let x as String:
            try container.encode(x)
        case let x as [Any]:
            try container.encode(x.map { AnyCodable($0) })
        case let x as [String: Any]:
            try container.encode(x.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
        }
    }
}

extension AnyCodable: CustomStringConvertible {
    var description: String {
        switch value {
        case let x as CustomStringConvertible:
            return x.description
        default:
            return String(describing: value)
        }
    }
}
