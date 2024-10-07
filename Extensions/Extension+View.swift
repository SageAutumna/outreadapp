//
//  Extension+View.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI
import MessageUI

extension View {
    var maxHeight: CGFloat {
        return UIScreen.main.bounds.height - UIScreen.main.bounds.minY
    }
    
    var maxWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }

    func navigationBarModifier(backgroundColor: UIColor = UIColor(Color(.mainBlue)),
                               foregroundColor: UIColor = UIColor(Color(.white100)),
                               tintColor: UIColor? = nil,
                               withSeparator: Bool = false) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, 
                                            foregroundColor: foregroundColor,
                                            tintColor: tintColor,
                                            withSeparator: withSeparator))
    }
    
    func applyBackButton() -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                        .padding(.bottom, 8)
                }
            }
    }
    
    func applyBookmarksButton() -> some View {
        self
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                        BookmarkButton {
                            print("Bookmark tapped")
                        }
                }
            }
    }
    
    func applyTitle(_ title: String) -> some View {
        self
            .navigationBarTitle(title, displayMode: .inline)
    }
    
    func changeTitle(_ title: String) -> some View {
        self
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(alignment: .center) {
                        Text(title)
                            .font(.customFont(font: .poppins, style: .medium, size: .s16))
                            .foregroundStyle(Color(.white100))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
    }

    func foregroundLinearGradient() -> some View {
        self
        .foregroundStyle(LinearGradient(colors: [Color(.white).opacity(0.7), Color.white.opacity(0.9)], 
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing))
    }
    
    func backgroundAngularGradient(radius : CGFloat=16, degree: Double=0) -> some View {
        self
            .background(
            RoundedRectangle(cornerRadius: radius, 
                             style: .continuous)
            .fill(AngularGradient(colors: [Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).opacity(0.9)],
                                  center: .center,
                                  angle: .degrees(degree)))
            .blur(radius: 10)
        )
    }
    
    func dynamicRoundedInnerShadow(color: Color = .white, radius: CGFloat = 3, cornerRadius: CGFloat = 10) -> some View {
        self.modifier(DynamicRoundedInnerShadowModifier(color: color, radius: radius, cornerRadius: cornerRadius))
    }

    func showAlert(isPresented: Binding<Bool>,
                   title: String,
                   description: String,
                   primaryButtonTitle: String,
                   action: @escaping () -> Void) -> some View {
        self
            .alert(isPresented: isPresented) {
                Alert(
                    title: Text(title),
                    message: Text(description),
                    primaryButton: .default(Text(primaryButtonTitle), action: {
                        action()
                    }),
                    secondaryButton: .cancel()
                )
            }
    }
    
    func sendEmail(to: String, subject: String, isPresented: Binding<Bool>) -> some View {
        self
            .sheet(isPresented: isPresented) {
                MailComposeView(to: to, subject: subject, isPresented: isPresented)
            }
    }
    
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
}
