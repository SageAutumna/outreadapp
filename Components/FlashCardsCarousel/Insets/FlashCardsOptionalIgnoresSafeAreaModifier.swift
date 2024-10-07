import SwiftUI

struct FlashCardsOptionalIgnoresSafeAreaModifier: ViewModifier {
    let edges: Edge.Set?
    
    func body(content: Content) -> some View {
        if let edges = edges {
            content
                .ignoresSafeArea(edges: edges)
        } else {
            content
        }
    }
}

extension View {
    func optionalIgnoresSafeArea(edges: Edge.Set? = .all) -> some View {
        modifier(FlashCardsOptionalIgnoresSafeAreaModifier(edges: edges))
    }
}
