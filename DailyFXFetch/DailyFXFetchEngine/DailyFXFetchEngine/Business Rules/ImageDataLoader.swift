//
// ImageDataLoader.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

public protocol ImageDataLoaderTask {
    func cancel()
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}
