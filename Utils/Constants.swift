//
//  Constants.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import Foundation
import SwiftUI

struct Constants {
    static let FacebookAppId = "487703407409741"
    static let FacebookClientToken = "2bb0bc492c575bbbde8e07c48ab29362"
    static let FacebookAppURLSchemeSuffix = "fb487703407409741"
    static let supabaseURL = URL(string: "https://hnecfnjmzbqwzcnqdrst.supabase.co")!
    static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhuZWNmbmptemJxd3pjbnFkcnN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI2MDg2NzYsImV4cCI6MjAzODE4NDY3Nn0.pMDglCYMOulTAVfGYI57yjN-dAXf3DMoVwrRAZkATNY"

    static let eulaURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let privacyURL = URL(string: "https://www.outread.ai/privacy")!
    static let termsURL = URL(string: "https://www.outread.ai/tos")!

    static let businessEmail = "app@out-read.com"
    static let businessSubject = "I'd like to get customn package"
    
    static let feedbackEmail = "app@out-read.com"
    static let feedbackSubject = "Feedback for OutRead"
    static let helpEmail = "app@out-read.com"
    static let helpSubject = "Help required"

    static let sharedSecret = "e803a9afc8dd466fad18054c0f99edbc"
    static let monthlyProductId = "monthly"
    static let annualProductId = "annual"
    
    static let featuredCategoryName = "featured"
    static let featuredCategoryId = "cm0qd74vu0000gagoi1kez0qb"
    static let tabbarHeight: CGFloat = 93
    static let interItemSpacing: CGFloat = 20
    static let categoryItemSpacing: CGFloat = 15
    static let topPadding: CGFloat = 15
    static let headerHeight: CGFloat = 30
    static let coverAspectRatio: CGFloat = 3.0 / 4.0
    static let autoCarouselSide: CGFloat = 80.0
    
    static let loadingPopup: MessagePopup = MessagePopup(message: "Processing...", isError: false)
    
    static let scrollGradientColors: [Color] = [
        Color(.mainBlue),
        Color(.mainBlue).opacity(0.2),
        Color(.mainBlue).opacity(0.1),
        Color(.mainBlue).opacity(0.05),
//        Color(.mainBlue).opacity(0.02),
        Color(.mainBlue).opacity(0.01),
        Color(.mainBlue).opacity(0.005),
//        Color(.mainBlue).opacity(0.002),
        Color(.mainBlue).opacity(0.001),
        Color(.mainBlue).opacity(0),
    ]
    
    static let loginGradientColors: [Color] = [
        Color(.mainBlue),
        Color(.mainBlue).opacity(0.7),
        Color(.mainBlue).opacity(0.06)
    ]
}
