//
//  PolicyView.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import SwiftUI

enum LinkType {
    case eula
    case privacy
    case terms
}

struct PolicyView: View {
    var linkType: LinkType
    
    var body: some View {
        HTMLView(url: url())
            .background(Color(.mainBlue))
    }
    
    private func url() -> URL {
        var url: URL
        switch linkType {
            case .eula:
                url = Constants.eulaURL
            case .privacy:
                url = Constants.privacyURL
            case .terms:
                url = Constants.termsURL
        }
        return url
    }
}

#Preview {
    PolicyView(linkType: .eula)
}
