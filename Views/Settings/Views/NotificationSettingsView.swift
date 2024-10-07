//
//  NotificationSettingsView.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import SwiftUI

struct NotificationSettingsView: View {
    private let items = NotificationItem.allCases
    
    var body: some View {
        VStack {
            List {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        print(item)
                    }, label: {
                        VStack{
                            HStack(spacing: 12) {
                                Text(item.title)
                                    .modifier(SettingsTextStyle())
                                
                                Spacer()
                                
                                Toggle(isOn: (item == .newBookReleases) ? .constant(true) : .constant(false), label: {
                                    EmptyView().frame(width: 0)
                                })
                                .frame(width: 70)
                                .scaleEffect(0.9)
                            }
                            if item != NotificationItem.emailNotification {
                                Divider()
                                    .background(Color(.white10))
                            }
                        }
                    })
                    .buttonStyle(PlainButtonStyle())
                    .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                .listRowBackground(Color(.mainBlue))
            }
            .listStyle(PlainListStyle())
        }
        .padding(.horizontal, 20)
        .background(Color(.mainBlue))
    }
}

#Preview {
    NotificationSettingsView()
}
