import SwiftUI

public struct FlashCardsCarouselConfiguration: Equatable {
    
    /// The padding around the card container. Defaults to `.init(top: 24, leading: 24, bottom: 32, trailing: 24)`.
    public var cardPadding: EdgeInsets
    
    /// The safe area edges that a card ignores. Can be set to `.top` to allow a card to affect status bar area (i.e. let an image or color reach the top of the screen). Defaults to `nil`.
    public var cardIgnoreSafeAreaEdges: Edge.Set?
    
    /// The padding around the bottom controls. Defaults to `.init(top: 0, leading: 24, bottom: 24, trailing: 24)`.
    public var bottomControlsPadding: EdgeInsets
    
    /// The spacing between the bottom controls. Defaults to `16`.
    public var bottomControlsSpacing: CGFloat
    
    /// The height of the navigation buttons. May be used to negate visual glitches if navigation button font size and icon size differ too much, if `nil`, defaults to intrinsic content size.
    public var navigationButtonHeight: CGFloat?
    
    /// The padding around the navigation button content. Defaults to `init(top: 16, leading: 16, bottom: 16, trailing: 16)`.
    public var navigationButtonContentPadding: EdgeInsets
    
    /// The squared size of navigation button icons, i.e. `xmark`, `arrow.left` and `arrow.right`. Defaults to `20`.
    public var navigationButtonIconSize: CGFloat
    
    /// The dismiss icon used in the navigation buttons. Defaults to `xmark`.
    public var navigationButtonDismissIcon: Image
    
    /// The previous icon used in the navigation buttons. Defaults to `arrow.left`.
    public var navigationButtonPreviousIcon: Image
    
    /// The next icon used in the navigation buttons. Defaults to `arrow.right`.
    public var navigationButtonNextIcon: Image
    
    /// The finish text used in the right navigation button on the last page. Defaults to `Let's start`.
    public var navigationButtonFinishText: String
    
    /// If `true`, shows navigation buttons at the bottom of the cards carousel. If `false`, hides the navigation buttons.
    public var showNavigationButtons: Bool
    
    /// If `true`, shows indicators at the bottom of the cards carousel. If `false`, hides the indicators.
    public var showIndicators: Bool
    
    /// If `true`, will allow the user to swipe the cards left and right, if `false`, prevents any swipe interaction.
    public var cardsSwipingEnabled: Bool
    
    /// The tint color of all carousel elements if not overidden. Including primary button background color, secondary button text color and indicator color.
    public var tintColor: Color
    
    /// The backgroundColor of the carousel view, i.e. the area arround the card.
    public var backgroundColor: Color
    
    /// The text color of content within the primary buttons, i.e. the right navigation button. Defaults to `.white`.
    public var primaryButtonForegroundColor: Color
    
    /// The background color of primary buttons, i.e. the right navigation button. Defaults to `tintColor`.
    public var primaryButtonBackgroundColor: Color?
    
    /// The text color of content within the secondary buttons, i.e. the left navigation button. If `nil`, defaults to `tintColor`.
    public var secondaryButtonForegroundColor: Color?
    
    /// The background color of primary buttons, i.e. the left navigation button. Defaults to `primaryButtonTextColor`, which defaults to `white`.
    public var secondaryButtonBackgroundColor: Color?
    
    /// The color of active indicators. If `nil`, defaults to `tintColor`.
    public var activeIndicatorColor: Color?
    
    /// The color of inactive indicators. If `nil`, defaults to `tintColor` with `0.5 opacity`.
    public var inactiveIndicatorColor: Color?
    
    /// The font used for all button texts, i.e. the skip and continue button below the center card.
    public var buttonTextFont: Font
    
    /// The corner radius of the card. Defaults to `24`.
    public var cardCornerRadius: CGFloat
    
    /// The corner radius of the buttons. Defaults to `16`.
    public var buttonCornerRadius: CGFloat
    
    /// The corner radius of the indicators. Defaults to `.infinity` to make them round.
    public var indicatorCornerRadius: CGFloat
    
    /// The spacing between indicators. Defaults to `6`.
    public var indicatorSpacing: CGFloat
    
    /// The size of each indicator, determines both width and height of circle. Defaults to `6`.
    public var indicatorSize: CGFloat
    
    /// The animation of the entire carousel. Defaults to `.default`, but replaced with `nil` during onAppear to prevent visual glitches in `nonSwipeableCards`.
    public var carouselAnimation: Animation?
    
    public init(
        cardPadding: EdgeInsets                         = .init(top: 20, leading: 20, bottom: 10, trailing: 20),
        cardIgnoreSafeAreaEdges: Edge.Set?              = nil,
        bottomControlsPadding: EdgeInsets               = .init(top: 0, leading: 14, bottom: 0, trailing: 14),
        bottomControlsSpacing: CGFloat                  = 8,
        navigationButtonHeight: CGFloat?                = nil,
        navigationButtonContentPadding: EdgeInsets      = .init(top: 10, leading: 10, bottom: 10, trailing: 10),
        navigationButtonIconSize: CGFloat               = 20,
        navigationButtonDismissIcon: Image              = .init(systemName: "xmark"),
        navigationButtonPreviousIcon: Image             = .init(systemName: "arrow.left"),
        navigationButtonNextIcon: Image                 = .init(systemName: "arrow.right"),
        navigationButtonFinishText: String              = "Done",
        showNavigationButtons: Bool                     = true,
        showIndicators: Bool                            = true,
        cardsSwipingEnabled: Bool                       = true,
        tintColor: Color                                = .blue,
        backgroundColor: Color                          = .gray,
        primaryButtonForegroundColor: Color             = .white,
        primaryButtonBackgroundColor: Color?            = nil,
        secondaryButtonForegroundColor: Color?          = nil,
        secondaryButtonBackgroundColor: Color?          = nil,
        activeIndicatorColor: Color?                    = nil,
        inactiveIndicatorColor: Color?                  = nil,
        buttonTextFont: Font                            = .system(size: 16),
        cardCornerRadius: CGFloat                       = 0,
        buttonCornerRadius: CGFloat                     = 10,
        indicatorCornerRadius: CGFloat                  = .infinity,
        indicatorSpacing: CGFloat                       = 6,
        indicatorSize: CGFloat                          = 6,
        carouselAnimation: Animation?                   = .default
    ) {
        self.cardPadding = cardPadding
        self.cardIgnoreSafeAreaEdges = cardIgnoreSafeAreaEdges
        self.bottomControlsPadding = bottomControlsPadding
        self.bottomControlsSpacing = bottomControlsSpacing
        self.navigationButtonHeight = navigationButtonHeight
        self.navigationButtonContentPadding = navigationButtonContentPadding
        self.navigationButtonIconSize = navigationButtonIconSize
        self.navigationButtonDismissIcon = navigationButtonDismissIcon
        self.navigationButtonPreviousIcon = navigationButtonPreviousIcon
        self.navigationButtonNextIcon = navigationButtonNextIcon
        self.navigationButtonFinishText = navigationButtonFinishText
        self.showNavigationButtons = showNavigationButtons
        self.showIndicators = showIndicators
        self.cardsSwipingEnabled = cardsSwipingEnabled
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.primaryButtonForegroundColor = primaryButtonForegroundColor
        self.primaryButtonBackgroundColor = primaryButtonBackgroundColor ?? tintColor
        self.secondaryButtonForegroundColor = secondaryButtonForegroundColor ?? tintColor
        self.secondaryButtonBackgroundColor = secondaryButtonBackgroundColor ?? primaryButtonForegroundColor
        self.activeIndicatorColor = activeIndicatorColor ?? tintColor
        self.inactiveIndicatorColor = inactiveIndicatorColor ?? tintColor.opacity(0.5)
        self.buttonTextFont = buttonTextFont
        self.cardCornerRadius = cardCornerRadius
        self.buttonCornerRadius = buttonCornerRadius
        self.indicatorCornerRadius = indicatorCornerRadius
        self.indicatorSpacing = indicatorSpacing
        self.indicatorSize = indicatorSize
        self.carouselAnimation = carouselAnimation
    }
    
    public static var example = FlashCardsCarouselConfiguration()
}
