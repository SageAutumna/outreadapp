//
//  BackButton.swift
//  Outread
//
//  Created by iosware on 19/08/2024.
//

import SwiftUI

struct BackButton: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        IconButton(width: 34,
                   icon: Image(.iconBackButton),
                   onTap: {
            router.pop()
        })
    }
}

#Preview {
    BackButton()
        .background(.black)
}
