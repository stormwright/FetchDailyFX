//
// ArticleDetailViewController.swift
// Created by Mikayil M on 20/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

class ArticleDetailViewController: UIViewController {
    
    @IBOutlet private(set) var detailView: ArticleDetailView!
    
    var viewModel: ArticleDetailViewModel<UIImage>? {
        didSet{ bindViewModel() }
    }    

    override func viewDidLoad() {
        super.viewDidLoad()
        bindDetailView()
        loadAuthors()
    }
    
    private func loadAuthors() {
        viewModel?.loadAuthors()
    }
    
    private func bindViewModel() {
        viewModel?.onImageLoad = { [weak self] image in
            self?.detailView.articleImageView.setImageAnimated(image)
        }
        
        viewModel?.onAuthorsLoad = adaptToCellControllers(forwardingTo: detailView, imageLoader: viewModel!.imageLoader)
    }
    
    private func bindDetailView() {
        guard let title = viewModel?.title,
              let date = viewModel?.displayTimestamp,
              let description = viewModel?.description else {
            return
        }
        detailView.setUpView(title: title, date: date, articleDescription: description)
    }
    
    private func adaptToCellControllers(forwardingTo view: ArticleDetailView, imageLoader: ImageDataLoader) -> ([Author]) -> Void {
        return { [weak view] authors in
            view?.tableModel = authors.map { author in
                AuthorCellController(
                    viewModel: AuthorCellViewModel(
                        model: author, imageLoader: imageLoader, imageTransformer: UIImage.init))
            }
        }
    }
}
