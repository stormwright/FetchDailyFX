//
// Author.swift
// Created by Mikayil M on 19/06/2021
// 
//

import Foundation

public struct Author: Hashable {
    public let name: String?
    public let title: String?
    public let descriptionShort: String?
    public let photo: URL?
    
    public init(name: String?, title: String?, descriptionShort: String?, photo: URL?) {
        self.name = name
        self.title = title
        self.descriptionShort = descriptionShort
        self.photo = photo        
    }
}
