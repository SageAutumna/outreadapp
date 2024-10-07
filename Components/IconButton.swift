//
//  IconButton.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI

struct IconButton: View {
    let width: CGFloat
    let icon: Image
    let iconColor: Color
    let selectedIcon: Image?
    let selectedIconColor: Color
    var onTap: (() -> Void)?

    @State var isSelected: Bool = false
    
    init(width: CGFloat = 48,
         icon: Image,
         iconColor: Color = .clear,
         selectedIcon: Image? = nil,
         selectedIconColor: Color = .clear,
         isSelected: Bool = false,
         onTap: (() -> Void)? = nil) {
        self.width = width
        self.icon = icon
        self.iconColor = iconColor
        self.selectedIcon = selectedIcon
        self.selectedIconColor = selectedIconColor
        self._isSelected = State(initialValue: isSelected)
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            isSelected.toggle()
            onTap?()
        } label: {
            if selectedIcon != nil && isSelected {
                selectedIcon?
                    .resizable()
                    .foregroundColor(selectedIconColor)
            } else {
                icon
                    .resizable()
                    .foregroundColor(iconColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: width, height: width)
    }
}

#Preview {
    IconButton(width: 44, icon: Image(.iconBookmarkFilled))
        .background(.black)
}
