//
//  Font.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import UIKit
import SwiftUI

enum CustomFonts: String {
    case poppins = "Poppins"
}

enum CustomFontStyle: String {
    case black      = "-Black"
    case bold       = "-Bold"
    case extraBold  = "-ExtraBold"
    case light      = "-Light"
    case extraLight = "-ExtraLight"
    case medium     = "-Medium"
    case regular    = "-Regular"
    case semiBold   = "-SemiBold"
    case thin       = "-Thin"
}

enum CustomFontSize: CGFloat {
    case s10 = 10.0
    case s12 = 12.0
    case s13 = 13.0
    case s14 = 14.0
    case s15 = 15.0
    case s16 = 16.0
    case s18 = 18.0
    case s20 = 20.0
    case s22 = 22.0
    case s24 = 24.0
    case s26 = 26.0
    case s28 = 28.0
    case s30 = 30.0
    case s32 = 32.0
}

extension UIFont {
    /// Choose your font to set up
    /// - Parameters:
    ///   - font: Choose one of your font
    ///   - style: Make sure the style is available
    ///   - size: Use prepared sizes for your app
    ///   - isScaled: Check if your app accessibility prepared
    /// - Returns: UIFont ready to show
    static func customFont(
        font: CustomFonts,
        style: CustomFontStyle,
        size: CustomFontSize,
        isScaled: Bool = true) -> UIFont {
        let fontName: String = font.rawValue + style.rawValue
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let sizeValue = size.rawValue + (isPad ? 6.0 : 0.0)
        guard let font = UIFont(name: fontName, size: sizeValue) else {
            debugPrint("Font can't be loaded")
            return UIFont.systemFont(ofSize: sizeValue)
        }
        return isScaled ? UIFontMetrics.default.scaledFont(for: font) : font
    }
}

extension Font {
    /// Choose your font to set up
    /// - Parameters:
    ///   - font: Choose one of your font
    ///   - style: Make sure the style is available
    ///   - size: Use prepared sizes for your app
    ///   - isScaled: Check if your app accessibility prepared
    /// - Returns: Font ready to show
    static func customFont(
        font: CustomFonts,
        style: CustomFontStyle,
        size: CustomFontSize,
        isScaled: Bool = true) -> Font {
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let sizeValue = size.rawValue + (isPad ? 6.0 : 0.0)
            let fontName: String = font.rawValue + style.rawValue
            return Font.custom(fontName, fixedSize: sizeValue)
    }
}

