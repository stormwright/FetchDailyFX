//
// Article.swift
// Created by Mikayil M on 19/06/2021
// 
//

import Foundation

public struct Article: Hashable {
    public let title: String?
    public let description: String?
    public let headlineImageUrl: URL?
    public let authors: [Author]
    public let displayTimestamp: Date
    
    public init(title: String?, description: String?, headlineImageUrl: URL?, authors: [Author], displayTimestamp: Date) {
        self.title = title
        self.description = description
        self.headlineImageUrl = headlineImageUrl
        self.authors = authors
        self.displayTimestamp = displayTimestamp
    }
}
