//
//  User.swift
//  Outread
//
//  Created by iosware on 27/08/2024.
//

import Foundation
import Supabase

struct AppUser: Codable, Identifiable {
    var id: String
    var supabaseUserId: String
    var email: String?
    let passwordHash: String?
//    let fullName: String?
//    let phone: String?
//    let state: String?
//    let city: String?
    var role: String? = Role.USER.rawValue
    
    init(supabaseUser: User) {//, fullName: String?, phone: String?, state: String?, city: String?) {
        self.id = supabaseUser.id.uuidString
        self.supabaseUserId = supabaseUser.id.uuidString
        self.email = supabaseUser.email
        self.passwordHash = supabaseUser.id.uuidString // authentication doesn't return it so using just id
//        self.fullName = fullName
//        self.phone = phone
//        self.state = state
//        self.city = city
    }
    
    enum Role: String {
        case USER
        case PAID_USER
    }
}
