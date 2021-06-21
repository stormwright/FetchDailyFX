//
// AppViewControllerFactory.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

final class AppViewControllerFactory: ArticlesViewControllerFactory {
    
    private let imageLoader: ImageDataLoader
    
    init(imageLoader: ImageDataLoader) {
        self.imageLoader = imageLoader
    }
    
    func articleDetailView(_ article: Article) -> UIViewController {
        let view = ArticleDetailViewUIComposer.detailViewComposedWith(article: article, imageLoader: imageLoader)
        return view
    }
}
