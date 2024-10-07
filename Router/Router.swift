//
//  Router.swift
//  Outread
//
//  Created by iosware on 17/08/2024.
//

import SwiftUI
import Combine

@MainActor
final class Router: ObservableObject {
    enum Route: Hashable, Identifiable {
        case start
        case startLogin
        case startInfo
        case login
        case signup
        case forgot
        
        case main
        case summary(Article)
        case playlist(Int)
        case category(Category)
        case article(Article)
        case altMetricsArticle(Article)
        case featuredArticle(Article)
    //    case article(ArticleViewModel)
        
        case settingsAccount
        case settingsAccountEdit
        case settingsMembership
        case settingsNotification
        case settingsChangePassword
        case settingsPrivacy
        case settingsTerms
        case settingsFeedback
        case settingsHelpCenter
        
        var id: Self { self }
    }

    // MARK: - Public properties
    @Published var path = NavigationPath()
    @Published var isPaymentPresented: Bool = false
    
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
            case .start:
                StartView()
                    .toolbar(.hidden, for: .navigationBar)
            case .startLogin:
                StartLoginView()
                    .toolbar(.hidden, for: .navigationBar)
            case .startInfo:
                StartLoginInfoView()
                    .toolbar(.hidden, for: .navigationBar)
            case .login:
                LoginView()
                    .toolbar(.hidden, for: .navigationBar)
            case .forgot:
                ForgotView()
                    .toolbar(.hidden, for: .navigationBar)
            case .signup:
                SignupView()
                    .toolbar(.hidden, for: .navigationBar)
                
            case .main:
                RootView()
                    .toolbar(.hidden, for: .navigationBar)
                
            case let .summary(article):
                SummaryView(article: article)
                    .navigationBarTitleDisplayMode(.inline)
                    .applyTitle("Latest Sumaries")
            case let .category(category):
                CategoryArticlesListView(category: category)
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle(category.name)
            case let .playlist(id):
                PlayListArticleView(id: id)
                    .navigationBarTitleDisplayMode(.inline)
                    .applyTitle("Playlist")
            case let .article(article):
                ArticleDetailView(article: article)
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("Reading")
            case let .altMetricsArticle(article):
                ArticleDetailView(article: article, isAltMetric: true)
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("Reading")
            case let .featuredArticle(article):
                ArticleDetailView(article: article)
                    .navigationBarTitleDisplayMode(.inline)
                    .applyTitle(article.title)
                
            
            case .settingsAccount:
                MyAccountView()
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("My Account")
            case .settingsAccountEdit:
                EditAccountView()
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("My Account")
            case .settingsMembership:
                ManageMembershipView()
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("Manage Membership")
            case .settingsNotification:
                NotificationSettingsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("Notification Settings")
            case .settingsChangePassword:
                ChangePasswordView()
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("Password & Security")
                    .padding(.top, 14)// TODO: find out why ignoring safe area
            case .settingsPrivacy:
                PolicyView(linkType: .privacy)
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("Privacy Policy")
            case .settingsTerms:
                PolicyView(linkType: .terms)
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("Terms and Conditions")
            case .settingsFeedback:
                FeedbackView()
                    .navigationBarTitleDisplayMode(.inline)
                    .changeTitle("Feedback")
            case .settingsHelpCenter:
                Text("Help Center")
//                HelpCenterView()
//                    .changeTitle("Eyebrows and Narcissist")
//                    .applyBookmarksButton()
        }
    }
    
    @inlinable
    @inline(__always)
    func push(_ appRoute: Route) {
        withAnimation {
            path.append(appRoute)
        }
    }
    
    @inlinable
    @inline(__always)
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    @inlinable
    @inline(__always)
    func popToRoot() {
        path.removeLast(path.count)
    }
}
