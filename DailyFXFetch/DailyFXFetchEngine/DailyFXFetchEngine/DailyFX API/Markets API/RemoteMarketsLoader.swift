//
// RemoteMarketsLoader.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

public class RemoteMarketsLoader: MarketsLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public typealias LoadResult = MarketsLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                completion(RemoteMarketsLoader.map(data, from: response))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> LoadResult {
        do {
            let articles = try MarketsMapper.map(data, from: response)
            return .success(articles.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteMarket {
    func toModels() -> [Market] {
        return map {
            Market(displayName: $0.displayName, marketId: $0.marketId)
        }
    }
}
