//
//  SettingsItem.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import Foundation
import SwiftUI

enum SettingsItem: CaseIterable, Identifiable {
//    case myAccount
    case manageMembership
//    case notificationSettings
    case changePassword
    case privacyPolicy
    case termsAndConditions
    case feedback
    case helpCentre
    case logout
    
    var id: Self { self }
    
    var title: String {
        switch self {
//            case .myAccount: return "My Account"
            case .manageMembership: return "Manage Membership"
//            case .notificationSettings: return "Notification Settings"
            case .changePassword: return "Change Password"
            case .privacyPolicy: return "Privacy Policy"
            case .termsAndConditions: return "Terms and Conditions"
            case .feedback: return "Feedback"
            case .helpCentre: return "Help" //"Help Centre"
            case .logout: return "Logout"
        }
    }
    
    var icon: Image {
        switch self {
//            case .myAccount: return Image(.iconMyAccount)
            case .manageMembership: return Image(.iconMembership)
//            case .notificationSettings: return Image(.iconNotifications)
            case .changePassword: return Image(.iconChangePassword)
            case .privacyPolicy: return Image(.iconPrivacyPolicy)
            case .termsAndConditions: return Image(.iconTermsAndConditions)
            case .feedback: return Image(.iconFeeback)
            case .helpCentre: return Image(.iconHelpCenter)
            case .logout: return Image(.iconLogout)
        }
    }
    
    var route: Router.Route? {
        switch self {
//            case .myAccount:
//                return .settingsAccount
            case .manageMembership:
                return .settingsMembership
//            case .notificationSettings:
//                return .settingsNotification
            case .changePassword:
                return .settingsChangePassword
            case .privacyPolicy:
                return .settingsPrivacy
            case .termsAndConditions:
                return .settingsTerms
            case .feedback:
                return nil //.settingsFeedback
            case .helpCentre:
                return nil
            case .logout:
                return nil
        }
    }
    
    func shouldSkip() -> Bool {
        // skip "Manage Membership" if user is a member
        return self == .manageMembership && UserDefaults.standard.bool(forKey: "isPremiumUser")
        || self == .changePassword && UserDefaults.standard.bool(forKey: "isSocialLogin")
    }
    
}
