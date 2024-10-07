//
//  TextStyles.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

struct LoginTitleBoldTextStyle: ViewModifier {
    var color: Color = .white
    var size: CustomFontSize = .s30
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.customFont(font: .poppins, style: .bold, size: size))
    }
}

struct LoginTitleTextStyle: ViewModifier {
    var color: Color = .white
    var size: CustomFontSize = .s30
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.customFont(font: .poppins, style: .medium, size: size))
    }
}

struct LoginSmallTextStyle: ViewModifier {
    var color: Color = Color(.white70)
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.customFont(font: .poppins, style: .medium, size: .s12))
    }
}

struct LoginButtonTextStyle: ViewModifier {
    var color: Color = .white
    var padding: CGFloat = 10
    func body(content: Content) -> some View {
        content
            .font(.customFont(font: .poppins, style: .medium, size: .s14))
            .foregroundColor(color)
            .padding(.init(top: padding, leading: 24, bottom: padding, trailing: 24))
    }
}

struct MainTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color(.textFieldBackground))
            .cornerRadius(10)
            .font(.customFont(font: .poppins, style: .medium, size: .s14))
            .foregroundColor(Color(.white80))
    }
}

struct SettingsTextStyle: ViewModifier {
    var color: Color = Color(.white100)
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.customFont(font: .poppins, style: .regular, size: .s16))
    }
}

struct SemiboldTextStyle: ViewModifier {
    var color: Color = Color(.white100)
    var size: CustomFontSize = .s16
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.customFont(font: .poppins, style: .semiBold, size: size))
    }
}

struct MediumTextStyle: ViewModifier {
    var color: Color = Color(.white100)
    var size: CustomFontSize = .s16
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.customFont(font: .poppins, style: .medium, size: size))
    }
}

struct RegularTextStyle: ViewModifier {
    var color: Color = Color(.white60)
    var size: CustomFontSize = .s13
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.customFont(font: .poppins, style: .regular, size: size))
            .lineSpacing(6)
    }
}

struct LightTextStyle: ViewModifier {
    var color: Color = .white
    var size: CustomFontSize = .s12
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.customFont(font: .poppins, style: .light, size: size))
            .lineSpacing(6)
    }
}


#Preview {
    VStack{
        Text("LoginTitleBoldTextStyle Title").modifier(LoginTitleBoldTextStyle())
        Text("LoginTitleTextStyle Text").modifier(LoginTitleTextStyle())
        Text("LoginSmallTextStyle Text").modifier(LoginSmallTextStyle())
        Text("LoginButtonTextStyle Text").modifier(LoginButtonTextStyle())
        Text("MainTextFieldStyle Text").modifier(MainTextFieldStyle())
        Text("SettingsTextStyle Text").modifier(SettingsTextStyle())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.mainBlue))
}
