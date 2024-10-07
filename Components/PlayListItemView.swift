//
//  PlayListItemView.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

struct PlayListItemView: View {
    let item: Article
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                //Image(item.imageId ?? "playlist0")
                Image("playlist0")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.width, alignment: .top)
                    .clipped()
                    .cornerRadius(8)
                
                Text(item.title)
                    .font(.customFont(font: .poppins, style: .semiBold, size: .s12))
                    .foregroundColor(Color("White100"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                
                Text(item.oneCardSummary.content[0])
                    .font(.customFont(font: .poppins, style: .medium, size: .s10))
                    .foregroundColor(Color("White100"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer()
                HStack {
                    DurationView(duration: item.estimatedReadingTime)
                    Spacer()
                    IconButton(width: 28,
                               icon: Image(.iconBookmark),
                               selectedIcon: Image(.iconBookmarkFilled))
                }
            }
            .background(.clear)
            .shadow(radius: 5)
        }
    }
}

#Preview {
    PlayListItemView(item: TempData.shared.featuredArticles()[0])
        .frame(width: 185, height: 265)
        .background(.black)
}
