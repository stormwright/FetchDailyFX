//
// MarketsUIComposer.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

final class MarketsUIComposer {
    private init() {}
    
    static func dashboardComposedWith(marketsLoader: MarketsLoader) -> MarketsViewController {
        let marketsViewModel = MarketsViewModel(
            marketsLoader: MainQueueDispatchDecorator(decoratee: marketsLoader))

        let controller = MarketsViewController.makeWith(
            viewModel: marketsViewModel)
        marketsViewModel.onMarketsLoad = adaptMarketsToCellControllers(
            forwardingTo: controller)

        return controller
    }
    
    private static func adaptMarketsToCellControllers(forwardingTo controller: MarketsViewController) -> ([Market]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                MarketCellController(
                    viewModel: MarketCellViewModel(model: model))
            }
        }
    }
}

private extension MarketsViewController {
    static func makeWith(viewModel: MarketsViewModel) -> MarketsViewController {
        let bundle = Bundle(for: MarketsViewController.self)
        let storyboard = UIStoryboard(name: "Markets", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! MarketsViewController
        controller.viewModel = viewModel
        controller.title = viewModel.title
        return controller
    }
}
