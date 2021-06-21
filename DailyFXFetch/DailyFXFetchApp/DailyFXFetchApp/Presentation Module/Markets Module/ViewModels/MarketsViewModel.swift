//
// MarketsViewModel.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import Foundation
import DailyFXFetchEngine

final class MarketsViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    private var marketsLoader: MarketsLoader?
    
    init(marketsLoader: MarketsLoader) {
        self.marketsLoader = marketsLoader
    }
    
    var title: String {
        return "Markets"
    }
    
    var onMarketsLoad: Observer<[Market]>?
    
    func load() {
        marketsLoader?.load(completion: { [weak self] (result) in
            guard let markets = try? result.get() else {
                return
            }
            self?.onMarketsLoad?(markets)
        })
    }
}
