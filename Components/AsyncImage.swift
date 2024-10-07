//
//  AsyncImage.swift
//  Outread
//
//  Created by iosware on 20/08/2024.
//

import SwiftUI
import SkeletonUI

struct AsyncImageViewSkeleton: View {
    @StateObject private var loader = ImageLoader()
    var url: String?
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    
    var body: some View {
        VStack {
            if let image = loader.image, self.url != nil {
                if let width = width, let height = height {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(Constants.coverAspectRatio,
                                     contentMode: .fill)
                        .frame(width: width, height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .id(loader.image)
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(Constants.coverAspectRatio,
                                     contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .id(loader.image)
                }
            } else {
                if let width = width, let height = height {
                    Image(.transparent)
                        .resizable()
                        .aspectRatio(Constants.coverAspectRatio,
                                     contentMode: .fill)
                        .skeleton(with: loader.image == nil, shape: .rectangle)
                        .frame(maxWidth: width, maxHeight: height)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .id(loader.image)
                } else {
                    Image(.transparent)
                        .resizable()
                        .aspectRatio(Constants.coverAspectRatio,
                                     contentMode: .fill)
                        .skeleton(with: loader.image == nil, shape: .rounded(RoundedType.radius(10)))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .id(loader.image)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear) // This creates a shape with rounded corners
                    .shadow(color: .white, radius: 3) // Apply the shadow to this shape
        )
        .onAppear {
            guard let url = self.url else { return }
            loader.load(from: url)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}


struct AsyncImageView: View {
    @StateObject private var loader = ImageLoader()
    var url: String?
    var aspectRatio: CGFloat = Constants.coverAspectRatio

    var body: some View {
        VStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(aspectRatio,
                                 contentMode: .fill)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Image(.transparent)
                    .resizable()
                    .aspectRatio(aspectRatio,
                                 contentMode: .fill)
                    .skeleton(with: loader.image == nil, shape: .rectangle)
                    .cornerRadius(10)
                    .clipped()
            }
        }
        .onAppear {
            if let url = self.url {
                loader.load(from: url)
            }
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

#Preview {
    AsyncImageViewSkeleton(url: "https://picsum.photos/300/400")
        .frame(width: 250)
}
