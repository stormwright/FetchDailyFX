//
// MarketsViewController.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit

class MarketsViewController: UITableViewController {
    
    var viewModel: MarketsViewModel?
    
    var tableModel = [MarketCellController]() {
        didSet { tableView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadMarkets()
    }
    
    private func loadMarkets() {
        viewModel?.load()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellController(forRowAt: indexPath).view(in: tableView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> MarketCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    

}
