import SwiftUI

struct FlashCardsCarouselPageControl: View {
    let currentPage: Int
    let numberOfPages: Int
    let config: FlashCardsCarouselConfiguration = .example

    var body: some View {
        HStack(spacing: config.indicatorSpacing) {
            Spacer()
            
            Text("\(currentPage + 1)/\(numberOfPages)")
                .font(.customFont(font: .poppins, style: .regular, size: .s14))
                .foregroundStyle(Color(.white80))
                .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                .frame(width: 50, height: 30)
                .background(Color(.white10))
                .cornerRadius(15)
                .transition(.opacity) // Add a transition effect
                .animation(.easeInOut, value: currentPage)
            Spacer()
        }
    }
}

#Preview {
    FlashCardsCarouselPageControl(currentPage: 3, numberOfPages: 10)
        .background(Color(.mainBlue))
}
