//
//  Preferences.swift
//  Outread
//
//  Created by iosware on 04/09/2024.
//

import Foundation
import Combine
import SwiftUI

final class Preferences {
    static let standard = Preferences(userDefaults: .standard)
    let userDefaults: UserDefaults

    /// Sends through the changed key path whenever a change occurs.
    var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()

    init(userDefaults: UserDefaults) {
      self.userDefaults = userDefaults
    }

    @UserDefault("isOnboardingShown")
    var isOnboardingShown: Bool = false

    @UserDefault("isInfoShown")
    var isInfoShown: Bool = false

    @UserDefault("isPremiumUser")
    var isPremiumUser: Bool = false

    @UserDefault("paymentId")
    var paymentId: String = ""
}
