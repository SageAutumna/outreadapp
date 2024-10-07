//
//  RouterView.swift
//  Outread
//
//  Created by iosware on 17/08/2024.
//

import SwiftUI

struct RouterView<Content: View>: View {
    @inlinable
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: Router.Route.self) {
                    router
                        .view(for: $0)
                        .applyBackButton()
                        .navigationBarModifier()
                        .background(Color(.mainBlue))
                }
                .sheet(isPresented: $router.isPaymentPresented) {
                    MembershipPopupView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.mainBlue))
                }
                .navigationBarBackButtonHidden(isToolbarHidden)
                .toolbar(isToolbarHidden ? .hidden : .visible, for: .navigationBar)
        }
        .environmentObject(router)
        .environment(\.navigationBarHidden, isToolbarHidden)
    }

    @Environment(\.navigationBarHidden) private var isToolbarHidden: Bool
    @StateObject private var router = Router()
    private let content: Content
}
