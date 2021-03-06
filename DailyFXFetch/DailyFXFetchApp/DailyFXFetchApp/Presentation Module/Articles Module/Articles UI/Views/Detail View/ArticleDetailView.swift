//
// ArticleDetailView.swift
// Created by Mikayil M on 20/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit

final class ArticleDetailView: UIView {
    
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var title: UILabel!
    @IBOutlet private(set) var date: UILabel!
    @IBOutlet private(set) var articleDescription: UILabel!
    
    var tableModel = [AuthorCellController]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func setUpView(title: String, date: Date, articleDescription: String) {
        self.title.text = title
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        self.date.text = formatter.string(from: date)
        self.articleDescription.text = articleDescription
    }
    
}

extension ArticleDetailView: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellController(forRowAt: indexPath).view(in: tableView)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> AuthorCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
