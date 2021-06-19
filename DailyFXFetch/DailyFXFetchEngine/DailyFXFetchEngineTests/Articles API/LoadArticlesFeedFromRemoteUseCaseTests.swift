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
    
    private let url: URL
    private let client: HTTPClientForArticles
    
    init(url: URL, client: HTTPClientForArticles) {
        self.url = url
        self.client = client
    }
    
    typealias LoadResult = ArticlesLoader.Result
    
    func load(completion: @escaping (LoadResult) -> Void) {
        client.get(from: url) { (result) in
            
        }
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
        messages.append((url, completion))
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
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // MARK: Helpers
    
    func makeSUT(url: URL = URL(string: "https://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteArticlesLoader, client: HTTPClientForArticlesSpy) {
        let client = HTTPClientForArticlesSpy()
        let sut = RemoteArticlesLoader(url: url, client: client)
        return (sut, client)
    }
}
