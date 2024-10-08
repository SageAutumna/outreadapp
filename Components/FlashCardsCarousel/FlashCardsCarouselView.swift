import SwiftUI

/// The FlashCardsCarousel package provides a configurable arrangement of swipe-able card views which can be used for tutorials and other flows.
/// Includes page indicators, skip, previous, next and finish buttons.
public struct FlashCardsCarouselView<Content> : View where Content : View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding private var selection: Int
    private var pageCount: Int
    private var config: FlashCardsCarouselConfiguration
    private var content: () -> Content
    
    /// The view size is determined onAppear.
    /// To avoid visual glitches in the nonSwipeableCards during appear, we set the overall carousel animation to nil.
    /// The animation is then restored 1 frame after onAppear, this way, there are no visual glitches and the carousel is still animated.
    @State private var viewSize: CGSize = .zero
    @State private var carouselAnimation: Animation? = nil
    
    private var isOnFirstPage: Bool {
        selection == 0
    }
    
    private var isOnLastPage: Bool {
        selection + 1 == pageCount
    }
    
    /// Gives the card carousel a base offset when swiping is disabled so that the first view is shown in the nonSwipeableCards view.
    private var pageBaseOffsetMultiplier: CGFloat {
        (CGFloat(pageCount) / 2.0) - 0.5
    }
    
    /// Initialise the FlashCardsCarouselView.
    /// - Parameters:
    ///   - selection: Currently visible card index, defaults to `0`, will be updated on interaction and can be set manually.
    ///   - pageCount: The total amount of pages / cards. The component can be used like a TabView, but as it is fiendishly hard to extract a view count from a ViewBuilder like Apple does, we request developers to manually provide the amount. Unexpected behavior will likely occur if the given page count is inaccurate.
    ///   - config: The configuration of the FlashCardsCarouselView, used to customise the visuals and interaction. Try `.example` for a simple config.
    ///   - content: The content you wish to show as cards. Use `.tag(..)` on each card to ensure selection is updated correctly.
    public init(
        selection: Binding<Int>,
        pageCount: Int,
        config: FlashCardsCarouselConfiguration,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.pageCount = pageCount
        self.config = config
        self.content = content
    }
    
    public var body: some View {
        VStack {
            if config.cardsSwipingEnabled {
//                swipeableCards
                swipableVerticalCards
            } else {
                nonSwipeableCards
            }
            
            if config.showNavigationButtons || config.showIndicators {
                bottomControls
                    .padding(config.bottomControlsPadding)
                    .background(GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                self.viewSize = proxy.size
                                DispatchQueue.main.async {
                                    self.carouselAnimation = config.carouselAnimation
                                }
                            }
                            .onChange(of: proxy.size) { newValue in
                                self.viewSize = newValue
                            }
                    })
            }
        }
        .background(config.backgroundColor.ignoresSafeArea())
        .animation(carouselAnimation)
        .optionalIgnoresSafeArea(edges: config.cardIgnoreSafeAreaEdges)
    }
    
    private var swipeableCards: some View {
        TabView(selection: $selection) {
            content()
                .cornerRadius(config.cardCornerRadius)
                .padding(config.cardPadding)
                .optionalIgnoresSafeArea(edges: config.cardIgnoreSafeAreaEdges)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var swipableVerticalCards: some View {
        ScrollView(.vertical){
            VStack(spacing: 0) {
                content()
                    .cornerRadius(config.cardCornerRadius)
                    .padding(config.cardPadding)
                    .frame(width: viewSize.width, height: viewSize.height)
                    .offset(y: viewSize.height * pageBaseOffsetMultiplier - CGFloat(selection) * viewSize.height)
                    .optionalIgnoresSafeArea(edges: config.cardIgnoreSafeAreaEdges)
            }
        }
        .frame(width: viewSize.width, height: viewSize.height * CGFloat(pageCount))
    }
    
    private var nonSwipeableCards: some View {
        HStack(spacing: 0) {
            content()
                .cornerRadius(config.cardCornerRadius)
                .padding(config.cardPadding)
                .frame(width: viewSize.width)
                .offset(x: viewSize.width * pageBaseOffsetMultiplier - CGFloat(selection) * viewSize.width)
                .optionalIgnoresSafeArea(edges: config.cardIgnoreSafeAreaEdges)
        }
        .frame(width: viewSize.width * CGFloat(pageCount))
    }
    
    private var bottomControls: some View {
        HStack(spacing: config.bottomControlsSpacing) {
            if config.showNavigationButtons {
                if isOnFirstPage {
                    Button(action: {}) {
                        Image(uiImage: UIImage())
                            .frame(width: config.navigationButtonIconSize, height: config.navigationButtonIconSize)
                            .foregroundColor(config.secondaryButtonForegroundColor)
                            .padding(config.navigationButtonContentPadding)
                            .frame(height: config.navigationButtonHeight)
                    }
                    .background(Color.clear)
                    .cornerRadius(config.buttonCornerRadius)
                } else {
                    Button(action: tappedLeftButton) {
                        leftButtonContent
                            .frame(width: config.navigationButtonIconSize, height: config.navigationButtonIconSize)
                            .foregroundColor(config.secondaryButtonForegroundColor)
                            .padding(config.navigationButtonContentPadding)
                            .frame(height: config.navigationButtonHeight)
                    }
                    .background(config.secondaryButtonBackgroundColor)
                    .cornerRadius(config.buttonCornerRadius)
                }
            }
            
            if !isOnLastPage || !config.showNavigationButtons {
                FlashCardsCarouselPageControl(currentPage: selection, numberOfPages: pageCount)
            }
            
            if config.showNavigationButtons {
                Button(action: tappedRightButton) {
                    rightButtonContent
                        .foregroundColor(config.primaryButtonForegroundColor)
                        .padding(config.navigationButtonContentPadding)
                        .frame(height: config.navigationButtonHeight)
                }
                .background(config.tintColor)
                .cornerRadius(config.buttonCornerRadius)
            }
        }
    }
    
    private var leftButtonContent: some View {
        isOnFirstPage ? config.navigationButtonDismissIcon : config.navigationButtonPreviousIcon
    }
    
    @ViewBuilder
    private var rightButtonContent: some View {
        if isOnLastPage {
            finishText
        } else {
            config.navigationButtonNextIcon
                .renderingMode(.template)
                .frame(width: config.navigationButtonIconSize, height: config.navigationButtonIconSize)
        }
    }
    
    private var finishText: some View {
        Text(config.navigationButtonFinishText)
            .font(config.buttonTextFont)
            .frame(maxWidth: .greatestFiniteMagnitude)
    }
    
    private func tappedLeftButton() {
        if isOnFirstPage {
            dismiss()
        } else {
            withAnimation {
                selection -= 1
            }
        }
    }
    
    private func tappedRightButton() {
        if isOnLastPage {
            dismiss()
        } else {
            withAnimation {
                selection += 1
            }
        }
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}


struct FlashCardsCarouselViewWrapper: View {
    @State private var selectedTab: Int = 0
    private let coloredExample = FlashCardsCarouselConfiguration(
        tintColor: Color(#colorLiteral(red: 0.9433208704, green: 0.9532698989, blue: 0.9745958447, alpha: 1)),
        backgroundColor: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)),
        primaryButtonForegroundColor: Color(#colorLiteral(red: 0.3045416772, green: 0.4229111373, blue: 0.8595631719, alpha: 1))
    )
        
    var body: some View {
        FlashCardsCarouselView(selection: $selectedTab, 
                               pageCount: 3,
                               config: coloredExample) {
            card("A").tag(0)
            card("B").tag(1)
            card("C").tag(2)
        }
    }
        
    private func card(_ name: String) -> some View {
        ZStack {
            Color(white: 0.95)
            Text(name)
        }
    }
}

#Preview {
    FlashCardsCarouselViewWrapper()
        .background(Color.green)
}
