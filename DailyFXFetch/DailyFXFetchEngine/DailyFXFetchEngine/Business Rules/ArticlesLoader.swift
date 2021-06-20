//
// ArticlesLoader.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

public protocol ArticlesLoader {
    typealias Result = Swift.Result<[Article], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
