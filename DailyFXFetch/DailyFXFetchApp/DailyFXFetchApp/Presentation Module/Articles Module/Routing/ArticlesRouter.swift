//
// ArticlesRouter.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

final class ArticlesRouter: Router {
    
    enum Destination {
        case detailView(article: Article, navigationController: UINavigationController)
        case errorView
    }
    
    private let factory: ArticlesViewControllerFactory
    
    public init(factory: ArticlesViewControllerFactory) {
        self.factory = factory
    }
    
    func route(to destination: Destination) {
        switch destination {
        case .detailView(let article, let navigationController):
            let detailVC = factory.articleDetailView(article)
            navigationController.pushViewController(detailVC, animated: true)
            
        case .errorView:
            break
        }
    }
}
