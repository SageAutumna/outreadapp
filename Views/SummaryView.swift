//
//  SummaryView.swift
//  Outread
//
//  Created by iosware on 18/08/2024.
//

import SwiftUI

struct SummaryView: View {
    let article: Article
    var body: some View {
        Text(article.title)
    }
}

#Preview {
    SummaryView(article: TempData.shared.summaryArticles()[0])
}
