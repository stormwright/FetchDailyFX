//
// ArticlesDashboardUIComposer.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

final class ArticlesDashboardUIComposer {
    private init() {}
    
    static func dashboardComposedWith(articlesLoader: ArticlesLoader, imageLoader: ImageDataLoader, router: ArticlesRouter) -> ArticlesDashboardViewController {
        let articlesViewModel = ArticlesDashboardViewModel(
            articlesLoader: MainQueueDispatchDecorator(decoratee: articlesLoader))

        let controller = ArticlesDashboardViewController.makeWith(
            viewModel: articlesViewModel, router: router)
        articlesViewModel.onArticlesLoad = adaptArticlesToCellControllers(
            forwardingTo: controller,
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))

        return controller
    }
    
    private static func adaptArticlesToCellControllers(forwardingTo controller: ArticlesDashboardViewController, imageLoader: ImageDataLoader) -> ([Article]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                ArticleCellController(viewModel:
                    ArticleCellViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
            }
        }
    }
}

private extension ArticlesDashboardViewController {
    static func makeWith(viewModel: ArticlesDashboardViewModel, router: ArticlesRouter) -> ArticlesDashboardViewController {
        let bundle = Bundle(for: ArticlesDashboardViewController.self)
        let storyboard = UIStoryboard(name: "ArticlesDashboard", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ArticlesDashboardViewController
        controller.viewModel = viewModel
        controller.router = router
        controller.title = viewModel.title
        return controller
    }
}

