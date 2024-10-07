//
//  VerticalPageView.swift
//  Outread
//
//  Created by iosware on 04/09/2024.
//

import SwiftUI

struct VerticalPageView: View {
    @StateObject var viewModel: ArticleDetailViewModel
    let summaries: [Article.Summary]
    @State private var currentIndex = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(summaries.enumerated()), id: \.offset) { index, summary in
                                let isLast = (index == summaries.count - 1)
                                ContentCardView(article: viewModel.article,
                                                summary: summary,
                                                cardHeight: geometry.size.height * 0.9,
                                                isLast: isLast)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .id(index)
                            }
                        }
                    }
                    .content.offset(y: CGFloat(currentIndex) * -geometry.size.height)
                    .animation(.easeInOut, value: currentIndex)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let threshold = geometry.size.height * 0.2
                                if value.translation.height < -threshold && currentIndex < summaries.count - 1 {
                                    currentIndex += 1
                                    updateReading()
                                } else if value.translation.height > threshold && currentIndex > 0 {
                                    currentIndex -= 1
                                }
                                withAnimation {
                                    scrollProxy.scrollTo(currentIndex, anchor: .top)
                                }
                            }
                    )
                }
                
                pager(height: geometry.size.height)

            }
            .background(Color(.mainBlue))
            .onAppear{
                jumpToCard()
            }
        }
    }
    
    private func jumpToCard() {
        if let currentReadingHeading = viewModel.currentReadingHeading, !currentReadingHeading.isEmpty,
            let idx = summaries.firstIndex(where: {$0.heading?.lowercased() == currentReadingHeading}) {
            withAnimation {
                currentIndex = idx
            }
        }
    }
    
    private func updateReading() {
        if currentIndex > 0,
            summaries.count > currentIndex,
           let heading = summaries[currentIndex].heading?.lowercased(),
           !heading.isEmpty {
            viewModel.updateReadingProgress(heading: heading)
        }
    }
    
    private func pager(height: CGFloat) -> some View {
        Text("\(currentIndex + 1)/\(summaries.count)")
            .modifier(RegularTextStyle(color: .white))
            .padding(.init(top: 8, leading: 14, bottom: 8, trailing: 14))
            .background(Color(.white10))
            .foregroundColor(.green)
            .cornerRadius(20)
            .padding(.bottom, height * CGFloat(summaries.count - 1))

    }
}

struct CardView: View {
    let text: String
    let cardHeight: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .modifier(RegularTextStyle(color: .white, size: .s14))
                .foregroundStyle(.white)
                .padding()
                .background(Color(.white5))
                .cornerRadius(10)
                .shadow(radius: 5)
            Spacer()
        }
        .frame(height: cardHeight)
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(Color(.mainBlue))
    }
}

struct VerticalPageViewWrapper: View {
    let sampleTexts = [
        "Page 1: At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus.",
        "Page 2: Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "Page 3: At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus."
    ]
    
    var body: some View {
        VerticalPageView(viewModel: ArticleDetailViewModel(article: TempData.shared.articles[0]),
                         summaries: TempData.shared.articles[0].defaultSummary)
    }
}

#Preview {
    VerticalPageViewWrapper()
//        .background(.black)
}
