//
// Market.swift
// Created by Mikayil M on 19/06/2021
// 
//

import Foundation

public struct Market: Hashable {
    public let displayName: String
    public let marketId: String
    
    public init(displayName: String, marketId: String) {
        self.displayName = displayName
        self.marketId = marketId
    }
}
