//
// Article.swift
// Created by Mikayil M on 19/06/2021
// 
//

import Foundation

struct Article: Hashable {
    let title: String
    let description: String
    let headlineImageUrl: URL
    let authors: [Author]
    let displayTimestamp: Date
}
