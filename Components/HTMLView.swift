//
//  HTMLView.swift
//  Outread
//
//  Created by iosware on 20/08/2024.
//

import SwiftUI
import WebKit

struct HTMLView: UIViewRepresentable {
    typealias UIViewType = WKWebView
 
    var url: URL?
//    {
//        guard let url = Bundle.main.url(forResource: "index", withExtension: "html") else {
//            return URL(string: "https://policies.google.com/privacy?hl=en-US")!
//        }
//        return url
//    }
 
    var htmlString: String? = nil
 
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
 
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let htmlString else {
            if let url = url {
                uiView.load(URLRequest(url: url))
            } else if let fileURL = Bundle.main.url(forResource: "index", withExtension: "html") {
                uiView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
            } else if let htmlString = htmlString {
                uiView.loadHTMLString(htmlString, baseURL: nil)
            }
            
            return
        }
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

#Preview {
    HTMLView()
}
