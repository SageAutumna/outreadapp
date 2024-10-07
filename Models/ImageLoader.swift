//
//  ImageLoader.swift
//  Outread
//
//  Created by iosware on 20/08/2024.
//

import UIKit
import Foundation
import Combine
import Nuke

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private lazy var imageDownloader = {
        return ImagePipeline(configuration: .withDataCache)
    }()
    private var downloadTask: ImageTask?
    
    func load(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        Task { [weak self] in
            guard let self = self else { return }
            self.downloadTask = self.imageDownloader.imageTask(with: url)
            
            do {
                // Await the image download
                let downloadedImage = try await self.downloadTask?.image
                // Set the image on the main queue
                await MainActor.run {
                    self.image = downloadedImage
                }
            } catch {
                print("Failed to download image for url \(url.absoluteString): \(error)")
            }
        }
    }
    
    func cancel() {
        downloadTask?.cancel()
    }
}
