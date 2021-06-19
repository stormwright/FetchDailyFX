//
// LoadArticlesFeedFromRemoteUseCaseTests.swift
// Created by Mikayil M on 19/06/2021
// 
//

import XCTest
@testable import DailyFXFetchEngine

protocol ArticlesLoader {
    typealias Result = Swift.Result<[Article], Error>
    
    func load(completion: @escaping (Result) -> Void)
}

protocol MarketsLoader {
    typealias Result = Swift.Result<[Market], Error>
    
    func load(completion: @escaping (Result) -> Void)
}

class RemoteArticlesLoader: ArticlesLoader {
    
    typealias LoadResult = ArticlesLoader.Result
    
    func load(completion: @escaping (LoadResult) -> Void) {
        
    }
    
}

protocol HTTPClientTask {
    func cancel()
}

protocol HTTPClientForArticles {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

class HTTPClientForArticlesSpy: HTTPClientForArticles {
    
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    private var messages = [(url: URL, completion: (HTTPClientForArticles.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientForArticles.Result) -> Void) -> HTTPClientTask {
        
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
}

class LoadArticlesFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: Helpers
    
    func makeSUT(url: URL = URL(string: "https://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteArticlesLoader, client: HTTPClientForArticlesSpy) {
        let client = HTTPClientForArticlesSpy()
        let sut = RemoteArticlesLoader()
        return (sut, client)
    }
}
