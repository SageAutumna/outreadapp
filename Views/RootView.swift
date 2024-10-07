//
//  RootView.swift
//  Outread
//
//  Created by iosware on 17/08/2024.
//

import SwiftUI

enum TabItem: Int, CaseIterable{
    case home = 0
    case bookmarks
    case search
    case settings
    
    var title: String{
        switch self {
        case .home:
            return "Home"
        case .bookmarks:
            return "Bookmark"
        case .search:
            return "Search"
        case .settings:
            return "Settings"
        }
    }
    
    var icon: Image {
        switch self {
        case .home:
                return Image(.tabHome)
        case .bookmarks:
            return Image(.tabBookmarks)
        case .search:
            return Image(.tabSearch)
        case .settings:
            return Image(.tabSettings)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var router: Router
    @Preference(\.isInfoShown) var isInfoShown
    @Preference(\.isPremiumUser) var isPremiumUser

    @State var selectedTab: TabItem = .home
    @StateObject var articleListViewModel = ArticleListViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(TabItem.home)

                BookmarksView()
                    .tag(TabItem.bookmarks)
                
                SearchView()
                    .tag(TabItem.search)
                

                SettingsView()
                    .tag(TabItem.settings)
            }
            .background(.black)
            .toolbar((selectedTab == .settings) ? .visible : .hidden, for: .navigationBar)
            .environmentObject(articleListViewModel)

            ZStack{
                HStack{
                    ForEach((TabItem.allCases), id: \.self){ item in
                        Button {
                            selectedTab = item
                        } label: {
                            TabItemView(image: item.icon,
                                        title: item.title,
                                        isActive: (selectedTab == item))
                        }
                    }
                }
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 20)
            }
            .frame(height: Constants.tabbarHeight)
            .background(Color.mainBlue)
            .roundedCorner(30, corners: [.topLeft, .topRight])
            .padding(0)
        }
        .shadow(color: Color(.white30), radius: 2, x: 0, y: -1)
        .background(Color(.mainBlue))
        .ignoresSafeArea()
        .onAppear {
            if !isInfoShown, !isPremiumUser {
                router.isPaymentPresented = true
                isInfoShown = true
            }
        }
    }
}

private func setWindowBackgroundColor(_ color: UIColor = UIColor(Color( .mainBlue))) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        window.backgroundColor = color
    }
}

extension RootView {
    func TabItemView(image: Image, title: String, isActive: Bool) -> some View{
        HStack(spacing: 10){
            Spacer()
            image
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fill)
                .foregroundColor(isActive ? Color(.mainBlue) : Color(.white100))
                .frame(width: (image == Image(.tabSettings) ? 25 : 21), height: (image == Image(.tabSettings) ? 25 : 21))

            if isActive{
                Text(title)
                    .font(.customFont(font: .poppins, style: .bold, size: .s16))
                    .foregroundColor(isActive ? Color(.mainBlue) : Color(.white100))
                    .animation(.easeInOut(duration: 0.2))
            }
            Spacer()
        }
        .frame(height: 44)
        .frame(minWidth: 60,
               maxWidth: isActive ? .infinity : 60)
        .background(isActive ? Color.tabActive : .clear)
        .cornerRadius(45)
    }
}

#Preview {
    RootView()
}
