//
//  MessagePopupModifier.swift
//  Outread
//
//  Created by iosware on 28/08/2024.
//

import SwiftUI
import PopupView

struct MessagePopup: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let isError: Bool
}

struct MessagePopupModifier: ViewModifier {
    @Binding var message: MessagePopup?
    
    func body(content: Content) -> some View {
        content
            .popup(item: $message) { popup in
                HStack {
                    Text(popup.message)
                        .font(.customFont(font: .poppins, style: .regular, size: .s16))
                        .foregroundColor(.black)
                        .padding(20)
                }
                .frame(maxWidth: .infinity)
                .padding(.init(top: 60, leading: 0, bottom: 20, trailing: 0))
                .background(popup.isError ? Color.red : Color.green)
                .cornerRadius(10)
            } customize: {
                $0
                    .type(.toast)
                    .position(.top)
                    .animation(.spring())
                    .autohideIn(3)
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.5))
            }
    }
}
struct LoadingPopupModifier: ViewModifier {
    @Binding var message: MessagePopup?
    
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea()
            .popup(item: $message) { popup in
                HStack(alignment: .center, spacing: 0){
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                        .padding(.init(top: 74, leading: 20, bottom: 10, trailing: 0))
                    
                    Text(popup.message)
                        .font(.customFont(font: .poppins, style: .regular, size: .s16))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.init(top: 74, leading: -20, bottom: 10, trailing: 20))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.95))
                .roundedCorner(10, corners: [.bottomLeft, .bottomRight])
                .padding(.init(top: 0, leading: 0, bottom: 20, trailing: 0))

            } customize: {
                $0
                    .type(.toast)
                    .position(.top)
                    .animation(.spring())
                    .autohideIn(3)
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.5))
            }
    }
}

extension View {
    func messagePopup(message: Binding<MessagePopup?>) -> some View {
        self.modifier(MessagePopupModifier(message: message))
    }
    func loadingPopup(message: Binding<MessagePopup?>) -> some View {
        self.modifier(LoadingPopupModifier(message: message))
    }
}
