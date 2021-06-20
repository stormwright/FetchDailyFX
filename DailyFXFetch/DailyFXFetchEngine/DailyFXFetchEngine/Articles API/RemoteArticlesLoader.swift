//
// RemoteArticlesLoader.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

public class RemoteArticlesLoader: ArticlesLoader {
    
    private let url: URL
    private let client: HTTPClientForArticles
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClientForArticles) {
        self.url = url
        self.client = client
    }
    
    public typealias LoadResult = ArticlesLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                completion(RemoteArticlesLoader.map(data, from: response))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> LoadResult {
        do {
            let articles = try ArticlesMapper.map(data, from: response)
            return .success(articles.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteArticle {
    func toModels() -> [Article] {
        return map {
            Article(title: $0.title, description: $0.description, headlineImageUrl: URL(string: $0.headlineImageUrl), authors: $0.authors.toModels(), displayTimestamp: $0.displayTimestamp.date)
        }
    }
}

private extension Array where Element == RemoteAuthor {
    func toModels() -> [Author] {
        return map { Author(name: $0.name, title: $0.title, descriptionShort: $0.descriptionShort, photo: URL(string: $0.photo)) }
    }
}
