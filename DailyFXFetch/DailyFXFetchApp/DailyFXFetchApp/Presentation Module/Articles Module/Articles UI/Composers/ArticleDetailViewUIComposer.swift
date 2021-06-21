//
// ArticleDetailViewUIComposer.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

final class ArticleDetailViewUIComposer {
    private init() {}
    
    static func detailViewComposedWith(article: Article, imageLoader: ImageDataLoader) -> ArticleDetailViewController {
        
        let viewModel = ArticleDetailViewModel(
            model: article,
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        
        let controller = ArticleDetailViewController.makeWith(viewModel: viewModel)
        
        return controller
    }
}

private extension ArticleDetailViewController {
    static func makeWith(viewModel: ArticleDetailViewModel) -> ArticleDetailViewController {
        let bundle = Bundle(for: ArticleDetailViewController.self)
        let storyboard = UIStoryboard(name: "ArticleDetailView", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ArticleDetailViewController
        controller.viewModel = viewModel
        controller.title = "Article Snapshot"
        return controller
    }
}

