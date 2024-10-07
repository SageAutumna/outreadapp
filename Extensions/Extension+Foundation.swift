//
//  Extension+String.swift
//  Outread
//
//  Created by iosware on 04/09/2024.
//

import Foundation

extension String{
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }
}

extension Date {
    var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
}

