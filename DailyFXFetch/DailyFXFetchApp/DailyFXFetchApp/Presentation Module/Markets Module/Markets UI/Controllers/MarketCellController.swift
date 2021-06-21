//
// MarketCellController.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit

final class MarketCellController {
    
    private let viewModel: MarketCellViewModel
    private var cell: MarketCell?
    
    init(viewModel: MarketCellViewModel) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = bound(tableView.dequeueReusableCell())
        return cell
    }
    
    func cancelLoad() {
        releaseCellForReuse()
    }
    
    private func bound(_ cell: MarketCell) -> MarketCell {
        self.cell = cell
        
        cell.marketName.text = viewModel.marketName
        cell.marketID.text = viewModel.marketID
        
        return cell
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
