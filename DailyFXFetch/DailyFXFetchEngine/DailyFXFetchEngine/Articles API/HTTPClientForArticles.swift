//
// HTTPClientForArticles.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClientForArticles {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
