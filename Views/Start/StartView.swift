//
//  StartView.swift
//  Outread
//
//  Created by iosware on 20/08/2024.
//

import SwiftUI
import Dependencies

struct StartView: View {
    @Namespace private var namespace
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var subscriptionViewModel = SubscriptionViewModel()
    
    @Dependency(\.syncManager) var syncManager
    
    @State private var showMainView = false
    @State var splashScreen  = true
    
    var body: some View {
        RouterView {
            VStack{
                if splashScreen {
                    SplashView()
                } else  if showMainView {
                    RootView()
                        .navigationBarHidden(true)
                } else {
                    StartLoginView()
                        .navigationBarHidden(true)
                }
            }
            .onAppear {
                if splashScreen {
                    checkSession()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: isPad ? .bottom :  .all)
        .environment(\.animationNamespace, namespace)
        .environmentObject(authViewModel)
        .environmentObject(subscriptionViewModel)
    }
    
    private func checkSession() {
        Task {
            await authViewModel.checkAndRefreshSession()
            await syncManager.startSyncing()
            showMainView = authViewModel.isSignedIn
            splashScreen = false
        }
    }
}

#Preview {
    StartView()
}
