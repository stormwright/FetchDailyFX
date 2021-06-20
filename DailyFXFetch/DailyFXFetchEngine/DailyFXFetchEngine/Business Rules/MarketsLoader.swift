//
// MarketsLoader.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

public protocol MarketsLoader {
    typealias Result = Swift.Result<[Market], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
