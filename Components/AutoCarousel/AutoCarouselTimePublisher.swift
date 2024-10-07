//
//  AutoCarouselTimePublisher.swift
//  Outread
//
//  Created by iosware on 23/08/2024.
//

import SwiftUI
import Combine

typealias AutoCarouselTimePublisher = Publishers.Autoconnect<Timer.TimerPublisher>

extension View {
    func onReceive(timer: AutoCarouselTimePublisher?, perform action: @escaping (Timer.TimerPublisher.Output) -> Void) -> some View {
        Group {
            if let timer = timer {
                self.onReceive(timer, perform: { value in
                    action(value)
                })
            } else {
                self
            }
        }
    }
}
