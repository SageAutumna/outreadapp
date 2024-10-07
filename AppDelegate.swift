//
//  AppDelegate.swift
//  Outread
//
//  Created by iosware on 28/08/2024.
//

import SwiftUI
//import FacebookCore
import GoogleSignIn
import Supabase
import SwiftyStoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    @Preference(\.isPremiumUser) var isPremiumUser
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let url = launchOptions?[.url] as? URL {
            SupabaseManager.shared.client.handle(url)
        }
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
            //FacebookCore
//        return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
#if DEBUG
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
          return true
        }
#endif
        SwiftyStoreKit.completeTransactions(atomically: true) { [weak self] purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        if purchase.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        self?.isPremiumUser = true
                        debugPrint("Restore success")
                    case .failed, .purchasing, .deferred:
                        debugPrint("Restore failed")
                        break
                    @unknown default: break
                }
            }
        }
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        SupabaseManager.shared.client.handle(url)
        
        var handled: Bool

          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }
        //FacebookCore
        //return ApplicationDelegate.shared.application(app, open: url, options: options)
        return false
    }

    func application(_: UIApplication, 
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
      let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
      configuration.delegateClass = SceneDelegate.self
      return configuration
    }
}

class SceneDelegate: UIResponder, UISceneDelegate {
  func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
      SupabaseManager.shared.client.handle(url)
  }
}
