//
// ArticleDetailViewModel.swift
// Created by Mikayil M on 20/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import Foundation
import DailyFXFetchEngine

final class ArticleDetailViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var task: ImageDataLoaderTask?
    private let model: Article
    let imageLoader: ImageDataLoader
    
    init(model: Article, imageLoader: ImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var title: String? {
        return model.title
    }
    
    var description: String? {
        return model.description
    }
    
    var displayTimestamp: Date {
        return model.displayTimestamp
    }
    
    var onAuthorsLoad: Observer<[Author]>?
    
    func loadAuthors() {
        onAuthorsLoad?(model.authors)
    }
}
