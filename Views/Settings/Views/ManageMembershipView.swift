//
//  ManageMembershipView.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import SwiftUI

struct ManageMembershipView: View {
    @EnvironmentObject var viewModel: SubscriptionViewModel
    @EnvironmentObject private var router: Router
    @Preference(\.isPremiumUser) var isPremiumUser

    @State private var messagePopup: MessagePopup?
    @State private var selectedPlan: SubscriptionItem = .annual
    @State private var showAlert = false
    @State private var askBusiness = false
    
    private let items = SubscriptionItem.allCases
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(text: "7 days free trial")
                FeatureRow(text: "Get instant access to 1000+ research paper summaries")
                FeatureRow(text: "You will be charged on the 7th day, cancel anytime before")
                //FeatureRow(text: "Personalized content")
            }
            .frame(maxWidth: .infinity)
            .background {
                Image(.backgroundMembership)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .padding(.vertical, 20)
            .cornerRadius(10)
            
            List {
                ForEach(items, id: \.self) { item in
                    Button(action: {
//                        if item == .business {
//                            askBusiness = true
//                        } else {
                            viewModel.startPayment(with: item) { result in
                                if result.success {
                                    isPremiumUser = true
                                }
                            }
//                        }
                    }, label: {
                        MembershipCardView(item: item)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listRowBackground(Color(.mainBlue))
            }
            .listStyle(PlainListStyle())
            
            Text("Your subscription will automatically renew unless canceled at least 24 hours before the end of the current period. You can manage or cancel your subscription anytime in your App Store account settings.")
                .modifier(MediumTextStyle(color: Color(.white80), size: .s12))
            
//            Spacer()
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    router.push(.settingsTerms)
                }) {
                    Text("Terms")
                        .modifier(MediumTextStyle(color: .white, size: .s12))
                        .padding()
                }

                Button(action: {
                    router.push(.settingsPrivacy)
                }) {
                    Text("Privacy")
                        .modifier(MediumTextStyle(color: .white, size: .s12))
                        .padding()
                }
                
                Button(action: {
                    viewModel.restorePurchases { result in
                        if result.success {
                            isPremiumUser = true
                        } else {
                            showAlert = true
                        }
                    }
                }, label: {
                    Text("Restore purchase")
                        .modifier(MediumTextStyle(color: .white, size: .s12))
                })
            }
            .padding(.vertical, 20)
        }
        .padding(.horizontal, 20)
        .background(Color(.mainBlue))
        .sendEmail(to: Constants.businessEmail, subject: Constants.businessSubject, isPresented: $askBusiness)
        .messagePopup(message: $messagePopup)
        .onChange(of: viewModel.errorMessage) { newValue in
            if let error = newValue {
                messagePopup = MessagePopup(message: error, isError: true)
            }
        }
    }
}

#Preview {
    ManageMembershipView()
        .environmentObject(SubscriptionViewModel())
        .environmentObject(Router())
}
