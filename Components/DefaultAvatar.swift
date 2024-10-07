//
//  DefaultAvatar.swift
//  Outread
//
//  Created by iosware on 02/09/2024.
//

import SwiftUI
import Dependencies

struct DefaultAvatar: View {
    @Dependency(\.authManager) var authManager
    
    var body: some View {
        let name: String = authManager.currentUser?.userMetadata["full_name"] as? String ?? authManager.currentUser?.email ?? ""
        let initials = String(name[name.startIndex]).uppercased() //+ String(name.split(separator: " ").last?[name.split(separator: " ")[1].startIndex] ?? "")

        ZStack {
            Circle().frame(width: 48, height: 48)
            Text(initials)
                .font(.customFont(font: .poppins, style: .semiBold, size: .s16))
                .foregroundStyle(Color(UIColor.white))
        }
        .background(Color(.mainBlue))
    }
}

#Preview {
    DefaultAvatar()
}
