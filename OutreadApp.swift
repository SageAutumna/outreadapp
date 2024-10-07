//
//  OutreadApp.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI
import Supabase

@main
struct OutreadApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .onOpenURL { url in
                    SupabaseManager.shared.client.handle(url)
                }
        }
    }
}
