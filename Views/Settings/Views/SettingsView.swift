//
//  SettingsView.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import SwiftUI
import Dependencies

struct SettingsView: View {
    @Dependency(\.authManager) var authManager
    @Preference(\.isPremiumUser) var isPremiumUser
    @EnvironmentObject private var router: Router

    @State private var showAlert = false
    @State private var showEmail = false
    @State private var isDeleteAlert = false
    @State private var isFeedbackEmail = false

    @State private var filteredItems: [SettingsItem] = []
    @State private var messagePopup: MessagePopup?
    @State private var loadingPopup: MessagePopup?
    @State private var isLoading: Bool = false
    
     var body: some View {
         VStack {
             
             Text("Settings")
                 .modifier(MediumTextStyle(color: .white, size: .s18))
                 .padding(.top, 64)
             
             List {
                 ForEach(filteredItems, id: \.self) { item in
                     Button(action: {
                         print(item)
                         if let route = item.route {
                             router.push(route)
                         } else {
                             switch item {
                                 case SettingsItem.feedback:
                                     isFeedbackEmail = true
                                     showEmail.toggle()
                                 case SettingsItem.helpCentre:
                                     showEmail.toggle()
                                 case SettingsItem.logout:
                                     showAlert = true
                                 default:
                                     break
                             }
                         }
                     }, label: {
                         HStack(spacing: 12) {
                             item.icon
                             
                             Text(item.title)
                                 .modifier(SettingsTextStyle())
                             
                             Spacer()
                         }
                     })
                     .buttonStyle(PlainButtonStyle())
                     .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
                 }
                 .listRowBackground(Color(.mainBlue))
             }
             .listStyle(PlainListStyle())

             HStack {
                 Button(action: {
                     isDeleteAlert = true
                     showAlert = true
                 }, label: {
                     HStack {
                         Image(.iconDeleteAccount)
                             .font(.system(size: 16, weight: .bold))
                         Text("Delete Account")
                             .modifier(SettingsTextStyle())
                             .foregroundStyle(Color(.delete))
                     }
                 })
                 
                 Spacer()
                 
                 Text(String(format: "Version %@",
                             Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"))
                 .modifier(LoginSmallTextStyle())
             }
             .padding(.bottom, 94)
         }
         .padding(.horizontal, 20)
         .background(Color(.mainBlue))
         .sendEmail(to: isFeedbackEmail ? Constants.feedbackEmail : Constants.helpEmail, subject: isFeedbackEmail ? Constants.feedbackSubject : Constants.helpSubject, isPresented: $showEmail)
         .showAlert(isPresented: $showAlert,
                    title: isDeleteAlert ? "Delete account" : "Logout",
                    description: isDeleteAlert ? "Are you sure you want to delete your account?" : "Are you sure you want to logout?",
                    primaryButtonTitle: isDeleteAlert ? "Delete" : "Logout",
                    action: {
             if isDeleteAlert {
                 deleteUser()
             } else {
                 signOut()
             }
         })
         .applyTitle("Settings")
         .loadingPopup(message: $loadingPopup)
         .messagePopup(message: $messagePopup)
         .onChange(of: isLoading) { newValue in
             if newValue {
                 loadingPopup = Constants.loadingPopup
             }
         }
         .onAppear {
             if authManager.isSocialLogin {
                 filteredItems = SettingsItem.allCases.filter { !$0.shouldSkip() && $0 != .changePassword }
             } else {
                 filteredItems = SettingsItem.allCases.filter { !$0.shouldSkip() }
             }
         }
     }
    
    private func deleteUser() {
        isLoading = true
        Task { @MainActor in
            await authManager.deleteUser()
            await authManager.signOut()
//            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            loadingPopup = nil
            messagePopup = MessagePopup(message: "Your account is scheduled for deletion and will be permanently removed within the next 2-3 days. If you wish to keep your account, please contact via 'Help' before the deletion process is completed.", isError: false)
            isLoading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            router.push(.login)
            }
        }
    }
    
    private func signOut() {
        isLoading = true
        Task {@MainActor in
            await authManager.signOut()
            isLoading = false
            router.push(.login)
        }
    }
}

#Preview {
    SettingsView()
}
