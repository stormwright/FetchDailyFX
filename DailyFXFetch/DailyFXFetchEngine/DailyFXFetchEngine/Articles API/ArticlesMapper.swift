//
// ArticlesMapper.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

final class ArticlesMapper {
    private struct Root: Decodable {
        let breakingNews: [RemoteArticle]
        let topNews: [RemoteArticle]
        let dailyBriefings: [RemoteArticle]
        let technicalAnalysis: [RemoteArticle]
        let specialReport: [RemoteArticle]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteArticle] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteArticlesLoader.Error.invalidData
        }
        var articles = [RemoteArticle]()
        
        articles.append(contentsOf: root.breakingNews)
        articles.append(contentsOf: root.topNews)
        articles.append(contentsOf: root.dailyBriefings)
        articles.append(contentsOf: root.technicalAnalysis)
        articles.append(contentsOf: root.specialReport)
        return articles
    }
}
