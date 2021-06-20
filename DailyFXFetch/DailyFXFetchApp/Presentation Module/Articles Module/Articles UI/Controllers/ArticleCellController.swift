//
// ArticleCellController.swift
// Created by Mikayil M on 20/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit

final class ArticleCellController {
    
    private let viewModel: ArticleCellViewModel<UIImage>
    private var cell: ArticleCell?
    
    init(viewModel: ArticleCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = bound(tableView.dequeueReusableCell())
        viewModel.loadImageData()
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        viewModel.cancelImageDataLoad()
    }
    
    private func bound(_ cell: ArticleCell) -> ArticleCell {
        self.cell = cell
        
        cell.title.text = viewModel.title
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        cell.date.text = formatter.string(from: viewModel.displayTimestamp)
        
        viewModel.onImageLoad = { [weak self] image in
            self?.cell?.articleImage.setImageAnimated(image)
        }
        
        return cell
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
