//
// HTTPURLResponse+StatusCode.swift
// Created by Mikayil M on 20/06/2021
// 
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    public var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
