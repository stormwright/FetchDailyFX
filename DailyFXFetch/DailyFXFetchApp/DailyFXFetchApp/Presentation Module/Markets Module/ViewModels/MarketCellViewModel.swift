//
// MarketCellViewModel.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import Foundation
import DailyFXFetchEngine

final class MarketCellViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    private let model: Market
    
    init(model: Market) {
        self.model = model
    }
    
    var marketName: String? {
        return model.displayName
    }
    
    var marketID: String? {
        return model.marketId
    }
}
