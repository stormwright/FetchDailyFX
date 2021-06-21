//
// MainQueueDispatchDecorator.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import Foundation
import DailyFXFetchEngine

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: ArticlesLoader where T == ArticlesLoader {
    func load(completion: @escaping (ArticlesLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: ImageDataLoader where T == ImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: MarketsLoader where T == MarketsLoader {
    func load(completion: @escaping (MarketsLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

