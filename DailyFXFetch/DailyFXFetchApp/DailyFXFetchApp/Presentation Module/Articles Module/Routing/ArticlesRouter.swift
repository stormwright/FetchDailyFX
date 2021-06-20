//
// ArticlesRouter.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

final class ArticlesRouter: Router {
    
    enum Destination {
        case detailView(article: Article)
        case errorView
    }
    
    private let factory: ArticlesViewControllerFactory
    
    private weak var navigationController: UINavigationController?
    
    public init(navigationController: UINavigationController, factory: ArticlesViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func route(to destination: Destination) {
        switch destination {
        case .detailView(let article):
            let detailVC = factory.articleDetailView(article)
            navigationController?.pushViewController(detailVC, animated: true)
        case .errorView:
            navigationController?.pushViewController(UIViewController(), animated: true)
        }
    }
}
