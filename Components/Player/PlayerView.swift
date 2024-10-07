//
//  PlayerView.swift
//  Outread
//
//  Created by iosware on 19/08/2024.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    
    @ObservedObject var player: Player
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    Text(player.formattedCurrentTime)
                        .font(.customFont(font: .poppins, style: .regular, size: .s14))
                        .foregroundColor(Color(.white60))

                    PlayerSlider(
                        value: Binding(
                            get: { player.currentTime },
                            set: { value in player.setTime(from: value) }
                        ),
                        range: 0...player.maxDuration
                    )
                    .frame(height: 30)

                    Text(player.formattedMaxDuration)
                        .font(.customFont(font: .poppins, style: .regular, size: .s14))
                        .foregroundColor(Color(.white60))
                }
                
                HStack {
                    
                    Spacer()

                    Button {
                        player.goBackward()
                    } label: {
                        Image(.iconPlayPrevious)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }

                    Button {
                        player.goBackward()
                    } label: {
                        Image(.iconPlayBackward)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        player.isPlaying ? player.pause() : player.play()
                    } label: {
                        Image(player.isPlaying ? "icon-play-pause" : "icon-play-play")
                            .resizable()
                            .frame(width: 52, height: 52)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        player.goForward()
                    } label: {
                        Image(.iconPlayForward)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }

                    Button {
                        player.goForward()
                    } label: {
                        Image(.iconPlayNext)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }

                    Spacer()
                    
                }

            }
            .background(Color(.mainBlue))
            .padding()
        }
    }
}

#Preview {
    PlayerView(player: Player(trackName: "The Founder Factor in Startups.mp3"))
        .background(Color(.mainBlue))
}
