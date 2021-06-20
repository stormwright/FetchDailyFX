//
// RemoteArticle.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

struct RemoteArticle: Codable {
    let title: String
    let description: String
    let headlineImageUrl: String
    let authors: [RemoteAuthor]
    let displayTimestamp: Int
}
