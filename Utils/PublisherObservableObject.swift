//
//  PublisherObservableObject.swift
//  Outread
//
//  Created by iosware on 04/09/2024.
//

import Combine

final class PublisherObservableObject: ObservableObject {
    var subscriber: AnyCancellable?
    
    init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        })
    }
}
