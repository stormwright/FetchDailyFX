//
// AppViewControllerFactory.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

final class AppViewControllerFactory: ArticlesViewControllerFactory {
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    
    
    func articleDetailView(_ article: Article) -> UIViewController {
        return UIViewController()
    }
}
