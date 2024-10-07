//
//  AppLifeCycleModifier.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI
import UIKit
typealias Application = UIApplication

/// Monitor and receive application life cycles,
/// inactive or active
struct AppLifeCycleModifier: ViewModifier {
    
    let active = NotificationCenter.default.publisher(for: Application.didBecomeActiveNotification)
    let inactive = NotificationCenter.default.publisher(for: Application.willResignActiveNotification)
    
    private let action: (Bool) -> ()
    
    init(_ action: @escaping (Bool) -> ()) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear() /// `onReceive` will not work in the Modifier Without `onAppear`
            .onReceive(active, perform: { _ in
                action(true)
            })
            .onReceive(inactive, perform: { _ in
                action(false)
            })
    }
}

extension View {
    func onReceiveAppLifeCycle(perform action: @escaping (Bool) -> ()) -> some View {
        self.modifier(AppLifeCycleModifier(action))
    }
}
