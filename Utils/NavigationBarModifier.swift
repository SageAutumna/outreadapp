//
//  NavigationBarModifier.swift
//  Outread
//
//  Created by iosware on 19/08/2024.
//

import UIKit
import SwiftUI


struct NavigationBarModifier: ViewModifier {
    init(backgroundColor: UIColor = UIColor(Color(.mainBlue)),
         foregroundColor: UIColor = UIColor(Color(.white100)),
         tintColor: UIColor? = nil,
         withSeparator: Bool = false){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() //???
        appearance.titleTextAttributes = [.foregroundColor: foregroundColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: foregroundColor]
        appearance.backgroundColor = backgroundColor
        if withSeparator {
            appearance.shadowColor = .clear
        }
        appearance.titleTextAttributes = [
            .font: UIFont.customFont(font: .poppins, style: .medium, size: .s18),
            .foregroundColor: UIColor(Color(.white100))
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        if let tintColor = tintColor {
            UINavigationBar.appearance().tintColor = tintColor
        }
    }
    func body(content: Content) -> some View {
        content
    }
}
