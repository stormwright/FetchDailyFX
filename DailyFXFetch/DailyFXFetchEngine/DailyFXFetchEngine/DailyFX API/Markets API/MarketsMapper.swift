//
// MarketsMapper.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

final class MarketsMapper {
    private struct Root: Decodable {
        let currencies: [RemoteMarket]
        let commodities: [RemoteMarket]
        let indices: [RemoteMarket]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteMarket] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteMarketsLoader.Error.invalidData
        }
        var articles = [RemoteMarket]()
        
        articles.append(contentsOf: root.currencies)
        articles.append(contentsOf: root.commodities)
        articles.append(contentsOf: root.indices)
        return articles
    }
}
