//
//  NotificationItem.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import Foundation

enum NotificationItem: CaseIterable, Identifiable {
    case newChallenges
    case newBookReleases
    case audiobookUpdates
    case dailyReadingGoal
    case authorEvents
    case libraryUpdates
    case specialOffersDiscounts
    case emailNotification
    
    var id: Self { self }
    
    var title: String {
        switch self {
            case .newChallenges: return "New Challenges"
            case .newBookReleases: return "New Book Releases"
            case .audiobookUpdates: return "Audiobook Updates"
            case .dailyReadingGoal: return "Daily Reading Goal"
            case .authorEvents: return "Author Events"
            case .libraryUpdates: return "Library Updates"
            case .specialOffersDiscounts: return "Special Offers & Discounts"
            case .emailNotification: return "Email Notifications"
        }
    }
}
