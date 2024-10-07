//
//  BookmarkButton.swift
//  Outread
//
//  Created by iosware on 19/08/2024.
//

import SwiftUI

struct BookmarkButton: View {
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        IconButton(width: 34,
                   icon: Image(.iconBookmarkFilled),
                   onTap: {
            onTap?()
        })
    }
}

#Preview {
    BookmarkButton()
        .background(.black)
}
