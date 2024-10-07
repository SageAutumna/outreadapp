//
//  ArticleDetailView.swift
//  Outread
//
//  Created by iosware on 18/08/2024.
//

import SwiftUI
import ScalingHeaderScrollView
import Shuffle

struct ArticleDetailView: View {
    @Namespace var animation
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel: ArticleDetailViewModel
    
    private let maxHeight = UIScreen.main.bounds.height - UIScreen.main.bounds.minY
    @State private var selectedArticle: Article
    @State private var carouselCurentIndex = 0
    @State private var sidesScaling: CGFloat = 0.8
    @State private var isWrap: Bool = false
    @State private var isAltMetric: Bool = false
    @State private var isCollapsed = false
    @State private var offset: CGFloat = .zero
    
    init(article: Article, isAltMetric: Bool = false) {
        _viewModel = StateObject(wrappedValue: ArticleDetailViewModel(article: article))
        self.isAltMetric = isAltMetric
        selectedArticle = article
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            if !isCollapsed {
                mainView
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)
            } else {
                cardsView
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(.mainBlue))
        .onAppear{
            viewModel.loadArticleDetails()
            if viewModel.relatedArticles.isEmpty {
                if isAltMetric {
                    viewModel.loadRelatedAltMetricArticles()
                } else {
                    viewModel.loadRelatedArticles()
                }
            }
        }
        .onChange(of: carouselCurentIndex) { newValue in
            withAnimation {
                loadArticle()
            }
        }
    }
    
    private var textView: some View {
        VStack(spacing: 0) {
            Text(viewModel.article.oneCardSummary.content[0])
                .font(.customFont(font: .poppins, style: .regular, size: .s12))
                .foregroundColor(Color(.textGray))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
        }
    }

    private var mainView: some View {
        let article = viewModel.relatedArticles.isEmpty ? viewModel.article : viewModel.relatedArticles[carouselCurentIndex]
        
        return VStack(spacing: 0) {
            carousel
            
            readButton
            
            authorView(article)
            
            categories(article)
            
            ScrollView {
                Text(article.oneCardSummary.content[0])
                    .font(.customFont(font: .poppins, style: .regular, size: .s12))
                    .foregroundStyle(.white)
                    .padding(.init(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onTapGesture(perform: {
                        isCollapsed = true
                    })
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
    }
    
    private var carousel: some View {
        return Group {
            switch viewModel.relatedArticlesLoadingState {
            case .idle, .loading:
                ProgressView()
                        .scaleEffect(2.0)
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded:
                if viewModel.relatedArticles.isEmpty {
                    Text("")
                        .frame(maxHeight: 60)
                } else {
                    VStack(spacing: 10) {
                        carouselView
                        carouselText
                    }
                    .background(Color(.white5))
                    .roundedCorner(20, corners: [.bottomLeft, .bottomRight])
                    .frame(maxWidth: .infinity, minHeight: maxHeight * 0.45, maxHeight: maxHeight * 0.45)
                }
            case .error:
                Text(" ").frame(maxHeight: 60)
            }
        }
    }
    
    private var carouselView: some View {
        let imageHeight = isPad ? (maxHeight * 0.3) : min((maxHeight * 0.4), 206.0)
        
        return AutoCarousel(viewModel.relatedArticles,
                            id: \.self,
                            index: $carouselCurentIndex,
                            spacing: Constants.interItemSpacing * 2,
                            headspace: isPad ? 200 : Constants.autoCarouselSide,
                            sidesScaling: sidesScaling,
                            isWrap: isWrap,
                            autoScroll: .inactive) { item in
            AsyncImageViewSkeleton(url: item.image?.src,
                           width: imageHeight * Constants.coverAspectRatio,
                           height: imageHeight)
            .frame(height: imageHeight + 10)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.top, 10)
    }
    
    private var carouselText: some View {
        let article = viewModel.relatedArticles[carouselCurentIndex]
        return VStack(spacing: 0) {
            Text(article.title)
                .font(.customFont(font: .poppins, style: .medium, size: .s18))
                .foregroundColor(.white)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .matchedGeometryEffect(id: "ArticleTitle-\(article.id)", in: animation)
            
            Text(article.subtitle)
                .font(.customFont(font: .poppins, style: .regular, size: .s12))
                .foregroundColor(Color(.textGray))
                .lineLimit(2)
                .matchedGeometryEffect(id: "ArticleSummary-\(article.id)", in: animation)
        }
        .frame(maxWidth: .infinity)
        .padding(.init(top: 0, leading: 20, bottom: 30, trailing: 20))
        .animation(.easeInOut, value: carouselCurentIndex)
    }
        
    private func authorView(_ article: Article) -> some View {
        return HStack(alignment: .top){
            VStack(alignment: .leading, spacing: 0){
                Text("Time")
                    .font(.customFont(font: .poppins, style: .light, size: .s12))
                    .foregroundStyle(Color(.white80))
                    .multilineTextAlignment(.leading)
                
                Text("\(article.estimatedReadingTime) min")
                    .font(.customFont(font: .poppins, style: .light, size: .s12))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.trailing, 20)

            Spacer()

            VStack(alignment: .trailing, spacing: 0){
                Text("Author")
                    .font(.customFont(font: .poppins, style: .light, size: .s12))
                    .foregroundStyle(Color(.white80))
                    .multilineTextAlignment(.trailing)
                                        
                Text(article.authorName.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.customFont(font: .poppins, style: .light, size: .s12))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.leading, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
        .padding(.top, -60)
    }
    
    private var readButton: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            Image(.backgroundButtonArticle)
                .aspectRatio(contentMode: .fit)
                .frame(height: 54)
                .padding(0)
            Button(action: {
                isCollapsed = true
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(.iconBook)
                            .foregroundColor(Color(.mainBlue))
                            .font(.system(size: 26))
                    )
            }
            .frame(width: 52)
            .offset(y: -10) // Move the button down to sit on the edge of the carousel
            .shadow(radius: 5)
        }
    }
    
    private var playButton: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            Image(.backgroundButtonArticle)
                .aspectRatio(contentMode: .fit)
                .frame(height: 54)
                .padding(0)
            Button(action: {
                
            }) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "headphones")
                            .foregroundColor(Color(.mainBlue))
                            .font(.system(size: 26))
                    )
            }
            .frame(width: 52)
            .offset(y: -10) // Move the button down to sit on the edge of the carousel
            .shadow(radius: 5)
        }
    }
    
    private func categories(_ article: Article) -> some View {
        return ArticleTagListView(tags: article.tags)
            .frame(height: 34)
            .padding(.vertical, 20)
    }

    private var cardsView: some View {
        VStack {
            VerticalPageView(viewModel: viewModel,
                             summaries: viewModel.article.defaultSummary)
        }
    }
    
    private func loadArticle() {
        viewModel.article = viewModel.relatedArticles[carouselCurentIndex]
    }
}

#Preview {
    ArticleDetailView(article: TempData.shared.articles[0])
}
