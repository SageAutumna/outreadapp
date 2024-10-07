//
//  CoreDataManager+Helpers.swift
//  Outread
//
//  Created by iosware on 03/09/2024.
//

import Foundation

// Helper methods for JSON conversion
extension CoreDataManager {
    func convertSummaryToJson(_ summary: Article.Summary) -> String? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(summary)
            return String(data: data, encoding: .utf8)
        } catch {
            debugPrint("Error encoding Summary: \(error)")
            return nil
        }
    }
    
    func convertSummaryArrayToJson(_ summaries: [Article.Summary]) -> String {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(summaries)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            debugPrint("Error encoding Summary array: \(error)")
            return ""
        }
    }
    
    func convertJsonToSummary(_ json: String?) -> Article.Summary? {
        guard let json = json, let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Article.Summary.self, from: data)
        } catch {
            debugPrint("Error decoding Summary: \(error)")
            return nil
        }
    }
    
    func convertJsonToSummaryArray(_ json: String?) -> [Article.Summary]? {
        guard let json = json, let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([Article.Summary].self, from: data)
        } catch {
            debugPrint("Error decoding Summary array: \(error)")
            return nil
        }
        }
}
