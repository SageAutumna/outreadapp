//
//  PlayListView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct PlayListView: View {
    @EnvironmentObject private var router: Router
    
    @State private var currentIndex: Int = 0
    @State private var offset: CGFloat = 0
    
    let geometry: GeometryProxy
    
    private let items = TempData.shared.healthArticles()
    private let interCardSpacing: CGFloat = 15
    private let aspectRatio: CGFloat = 170 / 220
    
    var body: some View {
        VStack(spacing: 10) {
            SectionHeaderView(title: "Playlist for you", onTap: {
                router.push(.playlist(1))
            })
                .frame(height: 20)
                .padding(.leading, 20)
            
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: interCardSpacing) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            PlayListItemView(item: item)
                                .frame(
                                    width: width(geometry),
                                    height: height(geometry)
                                )
                        }
                    }
                    .padding(.horizontal, interCardSpacing)
                }
                .content.offset(x: self.offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.offset = value.translation.width - CGFloat(self.currentIndex) * (width(geometry) + interCardSpacing)
                        }
                        .onEnded { value in
                            let cardWidth = width(geometry) + interCardSpacing
                            let predictedEndOffset = value.predictedEndTranslation.width - CGFloat(self.currentIndex) * cardWidth
                            let predictedIndex = -Int(round(predictedEndOffset / cardWidth))
                            
                            self.currentIndex = max(0, min(self.items.count - 1, predictedIndex))
                            withAnimation(.easeOut(duration: 0.3)) {
                                self.offset = -CGFloat(self.currentIndex) * cardWidth
                            }
                        }
                )
            }
            .frame(height: height(geometry))
        }
    }
    
    private func width(_ geometry: GeometryProxy) -> CGFloat {
        (geometry.size.width - 1 * interCardSpacing) / 2
    }
    
    private func height(_ geometry: GeometryProxy) -> CGFloat {
        width(geometry) / aspectRatio + Constants.headerHeight + Constants.interItemSpacing
    }
}

struct PlayListViewWrapper: View {
    var body: some View {
        GeometryReader { geometry in
            PlayListView(geometry: geometry)
        }
    }
}

#Preview {
    PlayListViewWrapper()
        .background(.black)
}
