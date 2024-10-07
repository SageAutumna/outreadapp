//
//  PlayerSlider.swift
//  Outread
//
//  Created by iosware on 19/08/2024.
//
import SwiftUI

struct PlayerSlider: View {
    
    var value: Binding<Double>
    var range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            Slider(value: value, in: range)
                .tint(Color(.mainGreen))
                .foregroundColor(Color(.sliderGray))
                .colorMultiply(Color(.mainGreen))
                .gesture(DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let percent = min(max(0, Double(value.location.x / geometry.size.width * 1)), 1)
                        let newValue = range.lowerBound + round(percent * (range.upperBound - range.lowerBound))
                        
                        self.value.wrappedValue = newValue
                    })
        }
    }
}

#Preview {
    PlayerSlider(value: .constant(20), range: 0...100)
}

