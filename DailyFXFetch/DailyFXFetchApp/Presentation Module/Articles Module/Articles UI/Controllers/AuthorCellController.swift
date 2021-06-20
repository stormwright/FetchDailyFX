//
// AuthorCellController.swift
// Created by Mikayil M on 20/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit

final class AuthorCellController {
    
    private let viewModel: AuthorCellViewModel<UIImage>
    private var cell: AuthorCell?
    
    init(viewModel: AuthorCellViewModel<UIImage>) {
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
    
    private func bound(_ cell: AuthorCell) -> AuthorCell {
        self.cell = cell
        
        cell.name.text = viewModel.name
        cell.title.text = viewModel.title
        cell.descriptionShort.text = viewModel.descriptionShort
        
        viewModel.onImageLoad = { [weak self] image in
            self?.cell?.photo.setImageAnimated(image)
        }
        
        return cell
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
