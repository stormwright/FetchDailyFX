//
// LoadArticlesFeedFromRemoteUseCaseTests.swift
// Created by Mikayil M on 19/06/2021
// 
//

import XCTest
import DailyFXFetchEngine

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
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoArticlesOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeArticlesJSON([], [], [], [])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversArticlesOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let author1 = Author(
            name: "Diego Colman",
            title: "Market Analyst",
            descriptionShort: "En DailyFX Desde: 2016. Experiencia: 5 a&#241;os operando con forex, 7 a&#241;os invirtiendo en activos de bolsa. Ha trabajado como economista de Am&#233;rica Latina, cubriendo pa&#237;ses como M&#233;xico, Argentina, Chile, Colombia y Brasil. Previamente, se ha desempe&#241;ado como analista de investigaci&#243;n de banca de inversiones",
            photo: URL(string: "https://a.c-dn.net/b/2WOWkt/Diego_Colman.png"))
        
        let article1 = makeArticle(
            title: "Crude Oil Price Forecast: Bullish Scenario Remains Intact amid Strengthening Demand",
            description: "Although the Fed hawkish bias has caused some reflationary position unwinding and anxiety about the outlook for commodities, the fundamental picture for oil has not changed and remains bullish.",
            headlineImageUrl: URL(string: "https://a.c-dn.net/b/2iX0wt/headline_OIL_PUMP_01.JPG")!,
            authors: [author1],
            displayTimestamp: 1624114800000.date)
        
        let author2 = Author(
            name: "Christopher Vecchio, CFA",
            title: "Senior Strategist",
            descriptionShort: "At DailyFX Since: 2008. Experience: Started trading in equities in 2004 and FX in 2008. Has worked with DailyFX since attending college in 2008 starting with an internship. Has consulted multi-national firms on FX hedging and has lectured at Duke Law School on FX derivatives trading.",
            photo: URL(string: "https://a.c-dn.net/b/2SwDd5/Christopher_Vecchio.png"))
        
        let article2 = makeArticle(
            title: "Euro Technical Analysis: Losing Steam Ahead of FOMC - Levels for EUR/GBP, EUR/JPY, EUR/USD",
            description: "The Euro has not made much progress in June and may be nearing a short-term inflection point as a result.",
            headlineImageUrl: URL(string: "https://a.c-dn.net/b/2OIPnn/headline_EU_FLAG.JPG")!,
            authors: [author2],
            displayTimestamp: 1623681900000.date)
        
        let articles = [article1.model, article2.model]
        
        expect(sut, toCompleteWith: .success(articles), when: {
            let json = makeArticlesJSON([], [article1.json], [article2.json], [])
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
        client.complete(withStatusCode: 200, data: makeArticlesJSON([], [], [], []))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: Helpers
    
    func makeSUT(url: URL = URL(string: "https://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteArticlesLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteArticlesLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteArticlesLoader.Error) -> RemoteArticlesLoader.LoadResult {
        return .failure(error)
    }
    
    private func makeArticle(title: String, description: String, headlineImageUrl: URL, authors: [Author], displayTimestamp: Date) -> (model: Article, json: [String: Any]) {
        
        let article = Article(title: title, description: description, headlineImageUrl: headlineImageUrl, authors: authors, displayTimestamp: displayTimestamp)
        
        let authorsDict = authors.compactMap { author in
            return [
                "name": author.name,
                "title": author.title,
                "descriptionShort": author.descriptionShort,
                "photo": author.photo!.absoluteString,
            ].compactMapValues { $0 }
        }
        
        
        let json = [
            "title": title,
            "description": description,
            "headlineImageUrl": headlineImageUrl.absoluteString,
            "authors": authorsDict,
            "displayTimestamp": Int(displayTimestamp.timeIntervalSince1970)
        ].compactMapValues { $0 }
        
        return (article, json)
    }
    
    private func makeArticlesJSON(_ breakingNews: [[String: Any]], _ topNews: [[String: Any]], _ dailyBriefings: [[String: Any]], _ technicalAnalysis: [[String: Any]]) -> Data {
        let json = [
            "breakingNews": breakingNews,
            "topNews": topNews,
            "dailyBriefings": dailyBriefings,
            "technicalAnalysis": technicalAnalysis,
            "specialReport": technicalAnalysis
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
