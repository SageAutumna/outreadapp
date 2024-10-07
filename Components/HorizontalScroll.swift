//
//  HorizontalScroll.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI

struct HorizontalScroll<Content: View>: View {
    var spacing: CGFloat = 20
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    content()
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    HorizontalScroll{
        ForEach(0..<10) { i in
            CategoryTagView(category: TempData.shared.categories[i],
                            selectedCategoryId: .constant("1"))
        }
    }
}
