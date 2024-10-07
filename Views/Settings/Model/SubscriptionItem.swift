//
//  SubscriptionItem.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import Foundation
import SwiftUI

enum SubscriptionItem: CaseIterable, Identifiable {
    case annual
    case monthly
//    case business
    
    var id: String { "\(self)" }
    
    var productId: String {
        switch self {
            case .annual: return Constants.annualProductId
            case .monthly: return Constants.monthlyProductId
//            case .business: return ""
        }
    }
    var title: String {
        switch self {
            case .annual: return "Annual"
            case .monthly: return "Monthly"
//            case .business: return "Business"
        }
    }
    var billed: String {
        switch self {
            case .annual: return "After the 7-day free trial, you will be automatically charged  %@"
            case .monthly: return "After the 7-day free trial, you will be automatically charged %@"
//            case .business: return "Contact us for business subscription"
        }
    }
    
    var freeTrial: String {
        switch self {
            case .annual: return "7"
            case .monthly: return "7"
//            case .business: return ""
        }
    }
    
    var cost: Double {
        switch self {
            case .annual:
                return 119.99
            case .monthly:
                return 19.99
//            case .business:
//                return 0
        }
    }
    
    var price: String {
        switch self {
            case .annual: return "120"
            case .monthly: return "20"
//            case .business: return "Custom Package"
        }
    }
    var period: String {
        switch self {
            case .annual: return "Year"
            case .monthly: return "Month"
//            case .business: return ""
        }
    }
    
    var isPopular: Bool {
        switch self {
            case .annual: return true
            case .monthly: return false
//            case .business: return false
        }
    }
    
    var icon: Image {
        switch self {
            case .annual: return Image(.iconMembershipAnnual)
            case .monthly: return Image(.iconMembershipMonthly)
//            case .business: return Image(.iconMembershipBusiness)
        }
    }
}
