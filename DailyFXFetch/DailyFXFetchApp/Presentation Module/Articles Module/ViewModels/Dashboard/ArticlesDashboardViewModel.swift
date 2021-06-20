//
// ArticlesDashboardViewModel.swift
// Created by Mikayil M on 20/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import Foundation
import DailyFXFetchEngine

final class ArticlesDashboardViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    private var articlesLoader: ArticlesLoader?
    
    init(articlesLoader: ArticlesLoader) {
        self.articlesLoader = articlesLoader
    }
    
    var title: String {
        return "Articles"
    }
    
    var onArticlesLoad: Observer<[Article]>?
    
    func load() {
        articlesLoader?.load(completion: { [weak self] (result) in
            guard let articles = try? result.get() else {
                return
            }
            self?.onArticlesLoad?(articles)
        })
    }    
}
