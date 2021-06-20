//
// LoadMarketsFromRemoteUseCaseTests.swift
// Created by Mikayil M on 20/06/2021
// 
//

import XCTest
import DailyFXFetchEngine

class RemoteMarketsLoader: MarketsLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    typealias LoadResult = MarketsLoader.Result
    
    func load(completion: @escaping (LoadResult) -> Void) {
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

struct RemoteMarket: Codable {
    let displayName: String
    let marketId: String
}

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

class LoadMarketsFromRemoteUseCaseTests: XCTestCase {
    
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
                let json = makeMarketsJSON([], [], [])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoMarketsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeMarketsJSON([], [], [])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversMarketsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let market1 = makeMarket(displayName: "EUR/USD", marketId: "EURUSD")
        let market2 = makeMarket(displayName: "Spot Gold", marketId: "GC")
        let market3 = makeMarket(displayName: "US 500", marketId: "DX")
        
        let markets = [market1.model, market2.model, market3.model]
        
        expect(sut, toCompleteWith: .success(markets), when: {
            let json = makeMarketsJSON([market1.json], [market2.json], [market3.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteArticlesLoader? = RemoteArticlesLoader(url: url, client: client)
        
        var capturedResults = [RemoteArticlesLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeMarketsJSON([], [], []))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: Helpers
    
    func makeSUT(url: URL = URL(string: "https://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteMarketsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMarketsLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteMarketsLoader.Error) -> RemoteMarketsLoader.LoadResult {
        return .failure(error)
    }
    
    private func makeMarket(displayName: String, marketId: String) -> (model: Market, json: [String: Any]) {
        
        let market = Market(displayName: displayName, marketId: marketId)
        
        let json = [
            "displayName": displayName,
            "marketId": marketId
        ].compactMapValues { $0 }
        
        return (market, json)
    }
    
    private func makeMarketsJSON(_ currencies: [[String: Any]], _ commodities: [[String: Any]], _ indices: [[String: Any]]) -> Data {
        let json = [
            "currencies": currencies,
            "commodities": commodities,
            "indices": indices
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteMarketsLoader, toCompleteWith expectedResult: RemoteMarketsLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteMarketsLoader.Error), .failure(expectedError as RemoteMarketsLoader.Error)):
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
