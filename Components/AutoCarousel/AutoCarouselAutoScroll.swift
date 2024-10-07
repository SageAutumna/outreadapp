//
//  AutoCarouselAutoScroll.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI

public enum AutoCarouselAutoScroll {
    case inactive
    case active(TimeInterval)
}


extension AutoCarouselAutoScroll {
    
    /// default active
    public static var defaultActive: Self {
        return .active(3)
    }
    
    /// Is the view auto-scrolling
    var isActive: Bool {
        switch self {
        case .active(let t): return t > 0
        case .inactive : return false
        }
    }
    
    /// Duration of automatic scrolling
    var interval: TimeInterval {
        switch self {
        case .active(let t): return t
        case .inactive : return 0
        }
    }
}
