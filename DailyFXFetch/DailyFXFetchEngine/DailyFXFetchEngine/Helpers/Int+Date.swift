//
// Int+Date.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

extension Int {
    public var date: Date {
        let eochTime = TimeInterval(self)
        let date = Date(timeIntervalSince1970: eochTime)
        return date
    }
}
