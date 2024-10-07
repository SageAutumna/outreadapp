//
//  PrefrenceKeys.swift
//  Outread
//
//  Created by iosware on 04/09/2024.
//

import SwiftUI

struct scrollPref: PreferenceKey {
    static var defaultValue: CGFloat = 0.0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        defaultValue = nextValue()
    }
}

