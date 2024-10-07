//
//  MembershipCardView.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import SwiftUI

struct MembershipCardView: View {
    let item: SubscriptionItem
    var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(Color(.white10))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.white20), lineWidth: isSelected ? 3 : 1)
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    item.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    Text(item.title)
                        .modifier(SemiboldTextStyle())
                    
                    Spacer()
                    if !item.freeTrial.isEmpty {
                        HStack(alignment: .firstTextBaseline, spacing: 2){
                            Text(item.freeTrial)
                                .modifier(SemiboldTextStyle(color: .white, size: .s24))
                            Text("days free trial")
                                .modifier(LoginSmallTextStyle(color: .white.opacity(0.8)))
                        }
                    }
                }
//                if item == .business {
//                    Text(item.price)
//                        .modifier(SemiboldTextStyle(color: .white, size: .s20))
//                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("$")
                            .modifier(SemiboldTextStyle(color: .white, size: .s12))
                        Text(item.price)
                            .modifier(SemiboldTextStyle(color: .white, size: .s24))
                        HStack(alignment: .firstTextBaseline, spacing: 2){
                            Text(" / \(item.period)")
                                .modifier(MediumTextStyle(color: Color(.white80), size: .s12))
                            
                        }
                    }
//                    .padding(.leading, 8)
//                    .overlay{
//                        HStack(alignment: .top){
//                            Text(Locale.current.currencySymbol ?? "$")
//                                .modifier(SemiboldTextStyle(color: .white, size: .s12))
//                            Spacer()
//                        }
//                        .padding(.bottom, 10)
//                    }
                    
                Text(String(format: item.billed, "$\(item.price) / \(item.period)"))
                        .modifier(MediumTextStyle(color: .white, size: .s12))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
//                        .padding(.bottom, item.isPopular ? 20 : 0)
                        .padding(.trailing, item.isPopular ? 100 : 10)
//                }
            }
            .padding(10)
            
            if item.isPopular {
                VStack{
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Most Popular")
                            .modifier(MediumTextStyle(color: .white, size: .s12))
                            .padding(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .background(Color(.white20))
                            .roundedCorner(16, corners: [.topLeft, .bottomRight])
                    }
                    
                }
                .clipped()
            }
        }
        .padding(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
        .background(Color(.mainBlue))
    }
}

#Preview {
    MembershipCardView(item: SubscriptionItem.annual,
                       isSelected: true)
        .frame(width: UIScreen.main.bounds.width, height: 180)
        .background(Color(.mainBlue))
}
