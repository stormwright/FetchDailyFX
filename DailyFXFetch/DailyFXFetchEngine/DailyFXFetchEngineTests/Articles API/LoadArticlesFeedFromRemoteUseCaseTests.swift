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
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(url: URL, client: HTTPClientForArticles) {
        self.url = url
        self.client = client
    }
    
    typealias LoadResult = ArticlesLoader.Result
    
    func load(completion: @escaping (LoadResult) -> Void) {
        client.get(from: url) { (result) in
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

extension Int {
    var date: Date {
        let eochTime = TimeInterval(self)
        let date = Date(timeIntervalSince1970: eochTime)
        return date
    }
}

private extension Array where Element == RemoteAuthor {
    func toModels() -> [Author] {
        return map { Author(name: $0.name, title: $0.title, descriptionShort: $0.descriptionShort, photo: URL(string: $0.photo)) }
    }
}

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

struct RemoteArticle: Codable {
    let title: String
    let description: String
    let headlineImageUrl: String
    let authors: [RemoteAuthor]
    let displayTimestamp: Int
}

struct RemoteAuthor: Codable {
    let name: String
    let title: String
    let descriptionShort: String
    let photo: String
}

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
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
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
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
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeArticlesJSON([], [], [], [])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    // MARK: Helpers
    
    func makeSUT(url: URL = URL(string: "https://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteArticlesLoader, client: HTTPClientForArticlesSpy) {
        let client = HTTPClientForArticlesSpy()
        let sut = RemoteArticlesLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteArticlesLoader.Error) -> RemoteArticlesLoader.LoadResult {
        return .failure(error)
    }
    
    private func makeArticlesJSON(_ breakingNews: [[String: Any]], _ topNews: [[String: Any]], _ dailyBriefings: [[String: Any]], _ technicalAnalysis: [[String: Any]]) -> Data {
        let json = [
            "breakingNews": breakingNews,
            "topNews": topNews,
            "dailyBriefings": dailyBriefings,
            "technicalAnalysis": technicalAnalysis,
            "specialReport": technicalAnalysis,
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteArticlesLoader, toCompleteWith expectedResult: RemoteArticlesLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteArticlesLoader.Error), .failure(expectedError as RemoteArticlesLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
