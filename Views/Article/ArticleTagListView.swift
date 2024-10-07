//
//  ArticleTagListView.swift
//  Outread
//
//  Created by iosware on 20/08/2024.
//

import SwiftUI
import Combine

struct ArticleTagListView: View {
    var tags: [String] = []
    @State private var items: [String] = []
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        HorizontalScroll{
            ForEach(tags, id: \.self) { tag in
                ArticleTagView(tag: tag)
                    .transition(AnyTransition.scale)
                    .id(tag)
            }
        }
    }    
}

#Preview {
    ArticleTagListView(tags: TempData.shared.articles[0].tags)
        .background(Color(.mainBlue))
}
