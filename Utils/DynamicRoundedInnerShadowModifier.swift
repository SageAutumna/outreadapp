//
//  DynamicRoundedInnerShadowModifier.swift
//  Outread
//
//  Created by iosware on 03/09/2024.
//

import SwiftUI

struct DynamicRoundedInnerShadowModifier: ViewModifier {
    var color: Color = .white
    var radius: CGFloat = 3.0
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(color, lineWidth: radius)
                        .blur(radius: radius)
                        .offset(x: 0, y: 0)
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.black, .clear]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height) // Match the size of the parent content
                )
        }
    }
}
