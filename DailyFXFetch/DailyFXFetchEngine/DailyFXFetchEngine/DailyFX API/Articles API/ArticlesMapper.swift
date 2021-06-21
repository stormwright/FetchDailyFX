//
// ArticlesMapper.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

final class ArticlesMapper {
    private struct Root: Decodable {
        let breakingNews: [RemoteArticle]?
        let topNews: [RemoteArticle]?
        let dailyBriefings: DailyBriefings?
        let technicalAnalysis: [RemoteArticle]?
        let specialReport: [RemoteArticle]?
    }
    
    private struct DailyBriefings: Decodable {
        let eu: [RemoteArticle]
        let asia: [RemoteArticle]
        let us: [RemoteArticle]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteArticle] {
        let decoder = JSONDecoder()
        
        guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteArticlesLoader.Error.invalidData
        }
        var articles = [RemoteArticle]()
        
        if let breakingNews = root.breakingNews {
            articles.append(contentsOf: breakingNews)
        }
        if let topNews = root.topNews {
            articles.append(contentsOf: topNews)
        }
        if let technicalAnalysis = root.technicalAnalysis {
            articles.append(contentsOf: technicalAnalysis)
        }
        if let dailyBriefings = root.dailyBriefings {
            articles.append(contentsOf: dailyBriefings.asia)
            articles.append(contentsOf: dailyBriefings.eu)
            articles.append(contentsOf: dailyBriefings.us)
        }
        if let specialReport = root.specialReport {
            articles.append(contentsOf: specialReport)
        }
 
        return articles
    }
}
