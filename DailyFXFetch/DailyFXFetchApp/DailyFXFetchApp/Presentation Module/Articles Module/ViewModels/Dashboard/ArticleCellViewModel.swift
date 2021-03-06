//
// ArticleCellViewModel.swift
// Created by Mikayil M on 20/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import Foundation
import DailyFXFetchEngine

final class ArticleCellViewModel<Image> {
    
    typealias Observer<T> = (T) -> Void
    
    private var task: ImageDataLoaderTask?
    private let model: Article
    private let imageLoader: ImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    init(model: Article, imageLoader: ImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var title: String? {
        return model.title
    }
    
    var displayTimestamp: Date {
        return model.displayTimestamp
    }
    
    var article: Article {
        return model
    }
    
    var onImageLoad: Observer<Image>?
    
    func loadImageData() {
        guard let url = model.headlineImageUrl else {
            return
        }
        task = imageLoader.loadImageData(from: url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: ImageDataLoader.Result) {
        guard let image = (try? result.get()).flatMap(imageTransformer) else {
            return
        }
        onImageLoad?(image)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
