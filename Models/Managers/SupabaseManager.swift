//
//  SupabaseManager.swift
//  Outread
//
//  Created by iosware on 28/08/2024.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(supabaseURL: Constants.supabaseURL, supabaseKey: Constants.supabaseKey)
    }
}

//let supabase = SupabaseClient(
//  supabaseURL: Constants.supabaseURL,
//  supabaseKey: Constants.supabaseKey,
//  options: .init(
////        auth: .init(redirectToURL: Constants.redirectToURL),
//    global: .init(
//      logger: ConsoleLogger()
//    )
//  )
//)

struct ConsoleLogger: SupabaseLogger {
  func log(message: SupabaseLogMessage) {
      debugPrint(message)
  }
}

