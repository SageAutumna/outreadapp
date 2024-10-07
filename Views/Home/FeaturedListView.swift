//
//  FeaturedListView.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI

struct FeaturedListView: View {
    @StateObject private var viewModel = ArticleListViewModel()
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 0){
            TabView(selection: $currentPage) {
                ForEach(Array(viewModel.featuredArticles.enumerated()), id: \.offset) { index, article in
                    FeaturedCardView(article: article)
                        .tag(index)
                        .transition(.asymmetric(
                            insertion: .opacity.animation(.easeInOut(duration: 0.3)),
                            removal: .opacity.animation(.easeInOut(duration: 0.3))
                        ))
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: isPad ? 350 : 200)
            .animation(.easeInOut, value: currentPage)

            HStack {
                Spacer()
                PageIndicator(numberOfPages: viewModel.featuredArticles.count, currentPage: currentPage)
            }
            .padding(.init(top: -12, leading: 0, bottom: 0, trailing: 20))
        }
        .onAppear{
            viewModel.loadFeaturedArticles()
        }
    }
    
}

struct FeaturedCardView: View {
    @EnvironmentObject private var router: Router
    let article: Article
    
    var body: some View {
        Button(action: {
            router.push(.article(article))
        }) {
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                Image(.backgroundTopscroll)
                    .resizable()
                    .aspectRatio(350/140, contentMode: .fill)
                    .frame(height: isPad ? 200 : 140)
                    .cornerRadius(15)
                    .padding(.trailing, 5)
                    .shadow(color:.white, radius: 3)

                HStack(alignment: .center, spacing: 0) {
                    AsyncImageViewSkeleton(url: article.image?.src, width: isPad ? 182 : 122, height: isPad ? 255 : 170)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 1)
                                .shadow(color:.white, radius: 3)
                        )

                    VStack(alignment: .leading, spacing: isPad ? 20 : 4) {
                        Text(article.title)
                            .font(.customFont(font: .poppins, style: .semiBold, size: .s18))
                            .lineLimit(isPad ? 3 : 2)
                            .foregroundStyle(Color(.white100))
                            .padding(.top, 10)

                        Text(article.subtitle)
                            .font(.customFont(font: .poppins, style: .regular, size: .s13))
                            .lineLimit(isPad ? 3 : 2)
                            .foregroundStyle(Color(.white60))

                        HStack(spacing: 7) {
                            Image(systemName: "book")
                                .frame(maxHeight: 40)
                                    .foregroundColor(Color(.mainYellow))
                                    .font(.customFont(font: .poppins, style: .regular, size: .s16))
                            Text("Start reading")
                                .foregroundStyle(Color(.mainYellow))
                                .font(.customFont(font: .poppins, style: .bold, size: .s15))
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.white : Color(.white40))
                    .frame(width: page == currentPage ? 9 : 7, height: page == currentPage ? 9 : 7)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedListView()
            .background(.black)
    }
}
