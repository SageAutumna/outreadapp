//
//  Segment.swift
//  Outread
//
//  Created by iosware on 18/08/2024.
//

import Foundation

public struct Segment: Identifiable {
    
    public let title: String
    public var object: Any?
    
    public var id: String { self.title }
    
    public init(title: String, object: Any? = nil) {
        self.title = title
        self.object = object
    }
}
