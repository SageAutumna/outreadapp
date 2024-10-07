//
//  MembershipPopupView.swift
//  Outread
//
//  Created by iosware on 25/08/2024.
//

import SwiftUI

struct MembershipPopupView: View {
    @EnvironmentObject var viewModel: SubscriptionViewModel
    @EnvironmentObject private var router: Router
    
    @Preference(\.isInfoShown) var isInfoShown
    @Preference(\.isPremiumUser) var isPremiumUser
    
    @State private var selectedPlan: SubscriptionItem = .annual
    @State private var messagePopup: MessagePopup?
    @State private var loadingPopup: MessagePopup?
    @State private var showAlert = false
    @State private var showInfo = false
    @State private var linkType: LinkType = .eula
    
    private let items = [SubscriptionItem.annual, SubscriptionItem.monthly]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        Text("Get 7 days free access")
                            .modifier(SemiboldTextStyle(color: .white, size: isPad ? .s26 : .s26))
                            .multilineTextAlignment(.center)
                        Text("to the entire library")
                            .modifier(MediumTextStyle(color: .white, size: isPad ? .s26 : .s22))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        FeatureRow(text: "7 days free trial")
                        FeatureRow(text: "Get instant access to 1000+ research paper summaries")
                        FeatureRow(text: "You will be charged on the 7th day, cancel anytime before")
                    }
                    .background {
                        Image(.backgroundMembership)
                            .resizable()
                            .padding(.horizontal, -50)
                            .padding(.vertical, -20)
                    }
                    .padding(18)
                    .cornerRadius(10)
                    
                    VStack(spacing: 20) {
                        ForEach(items, id: \.self) { item in
                            Button(action: {
                                selectedPlan = item
                            }, label: {
                                PlanView(item: item)
                                    .background(selectedPlan == item ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedPlan == item ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .contentShape(Rectangle())
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Button(action: {
                        viewModel.startPayment(with: selectedPlan) { result in
                            if result.success {
                                isPremiumUser = true
                                messagePopup = MessagePopup(message: "You have successfully subscribed", isError: false)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    router.isPaymentPresented = false
                                }
                            } else {
                                messagePopup = MessagePopup(message: "There was error during subscription", isError: true)
                            }
                        }
                    }) {
                        Text("Try free for 7 days")
                            .modifier(MediumTextStyle(color: .black, size: .s14))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                    
                    HStack(alignment: .center, spacing: 20) {
                        Button(action: {
                            linkType = .terms
                            showInfo = true
                        }) {
                            Text("Terms")
                                .modifier(MediumTextStyle(color: .white, size: .s12))
                                .padding()
                        }

                        Button(action: {
                            linkType = .eula
                            showInfo = true
                        }) {
                            Text("Privacy")
                                .modifier(MediumTextStyle(color: .white, size: .s12))
                                .padding()
                        }

                        Button(action: {
                            viewModel.restorePurchases { result in
                                if result.success {
                                    isPremiumUser = true
                                    messagePopup = MessagePopup(message: "You have successfully restored subscription", isError: false)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        router.isPaymentPresented = false
                                    }
                                } else {
                                    showAlert = true
                                    messagePopup = MessagePopup(message: "There was error during subscription", isError: true)
                                }
                            }
                        }) {
                            Text("Restore")
                                .modifier(MediumTextStyle(color: .white, size: .s12))
                                .padding()
                        }
                    }
                    .padding(.bottom, isPad ? 40 : 0)
                    
                }
                .padding(.horizontal, 20)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .loadingPopup(message: $loadingPopup)
            .messagePopup(message: $messagePopup)
            .onChange(of: viewModel.isLoadingPayment) { newValue in
                if newValue {
                    loadingPopup = Constants.loadingPopup
                }
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                if let error = newValue {
                    loadingPopup = nil
                    messagePopup = MessagePopup(message: error, isError: true)
                }
            }
            .sheet(isPresented: $showInfo) {
                PolicyView(linkType: .eula)
            }
            .onAppear {
                isInfoShown = true
            }
        }
        .background(Color(.mainBlue))
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "checkmark")
                .foregroundColor(.white)
                .padding(.top, 2)
            Text(text)
                .modifier(MediumTextStyle(size: isPad ? .s18 : .s14))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
}

struct PlanView: View {
    let item: SubscriptionItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.title)
                    .modifier(MediumTextStyle(color: .white, size: .s16))
                Spacer()
                if item.isPopular {
                    HStack {
                        Text("POPULAR")
                            .modifier(MediumTextStyle(color: Color(.mainBlue), size: .s10))
                            .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .background(Color(.green))
                            .cornerRadius(10)
//                        Text("50% OFF")
//                            .modifier(MediumTextStyle(color: Color(.mainBlue), size: .s10))
//                            .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
//                            .background(Color(.green))
//                            .cornerRadius(10)
                    }
                }

            }
            
            HStack{
                Text(String(format: item.billed, "$\(item.price)/\(item.period)"))
                    .modifier(LightTextStyle(color: .white, size: .s12))
                Spacer()
                Text("$\(item.price) / \(item.period)")
                    .modifier(LightTextStyle(color: Color(.green)))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cornerRadius(10)
        .overlay(
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.green), lineWidth: 1)
            }
        )
    }
}

#Preview {
    MembershipPopupView()
        .environmentObject(SubscriptionViewModel())
        .environmentObject(Router())
}
