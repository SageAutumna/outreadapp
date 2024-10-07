//
//  HorizontalScrollWrapper.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

struct HorizontalScrollWrapper<Content: View>: View {
    let totalItems: Int
    let itemsPerScreen: CGFloat
    let itemSpace: CGFloat
    let content: Content
    
    @State private var scrollPosition: Int?

    init(totalItems: Int, itemsPerScreen: CGFloat, itemSpace: CGFloat = Constants.interItemSpacing, @ViewBuilder content: () -> Content) {
        self.totalItems = totalItems
        self.itemsPerScreen = itemsPerScreen
        self.itemSpace = itemSpace
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            let itemWidth = (geometry.size.width - (itemsPerScreen - 1) * itemSpace) / itemsPerScreen

            if #available(iOS 17.0, *) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: itemSpace) {
                        content
                            .frame(width: itemWidth)
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollPosition(id: $scrollPosition)
                .scrollIndicators(.hidden)

            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: itemSpace) {
                        content
                            .frame(width: itemWidth)
                    }
                }
                .content.offset(x: -CGFloat(scrollPosition ?? 0) * (geometry.size.width + itemSpace))
                .gesture(
                    DragGesture()
                     .onEnded { value in
                            let predictedOffset = value.predictedEndTranslation.width
                            let targetOffset = round(predictedOffset / (itemWidth + itemSpace))
                            withAnimation {
                                scrollPosition = max(0, min(totalItems - 1, (scrollPosition ?? 0) - Int(targetOffset)))
                            }
                        }
                )
            }
        }
    }
}

#Preview {
    HorizontalScrollWrapper(totalItems: 4, itemsPerScreen: 2.5, itemSpace: 20) {
        Text("a")
            .multilineTextAlignment(.center)
            .frame(height: 360)
            .frame(maxWidth: .infinity)
            .background(.red)
        Text("b")
            .multilineTextAlignment(.center)
            .frame(height: 360)
            .frame(maxWidth: .infinity)
            .background(.blue)
        Text("c")
            .multilineTextAlignment(.center)
            .frame(height: 360)
            .frame(maxWidth: .infinity)
            .background(.orange)
        Text("d")
            .multilineTextAlignment(.center)
            .frame(height: 360)
            .frame(maxWidth: .infinity)
            .background(.green)
    }
//
}
