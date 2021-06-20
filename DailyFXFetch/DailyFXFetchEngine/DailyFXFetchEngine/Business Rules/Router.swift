//
// Router.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import Foundation

public protocol Router {
    associatedtype Destination

    func route(to destination: Destination)
}
