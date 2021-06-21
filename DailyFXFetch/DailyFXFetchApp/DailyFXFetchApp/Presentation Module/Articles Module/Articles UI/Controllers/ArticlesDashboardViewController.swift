//
// ArticlesDashboardViewController.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit

class ArticlesDashboardViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    var viewModel: ArticlesDashboardViewModel?
    
    var tableModel = [ArticleCellController]() {
        didSet { tableView.reloadData() }
    }
    
    var router: ArticlesRouter?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadArticles()
    }
    
    private func loadArticles() {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = cellController(forRowAt: indexPath).loadModel()
        if let navigationController = self.navigationController {
            router?.route(to: .detailView(article: model, navigationController: navigationController))
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> ArticleCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
