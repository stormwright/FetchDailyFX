//
// ArticlesViewControllerFactory.swift
// Created by Mikayil M on 21/06/2021
// Copyright © 2021 Mikayil M. All rights reserved.
//

import UIKit
import DailyFXFetchEngine

protocol ArticlesViewControllerFactory {
    func articleDetailView(_ article: Article) -> UIViewController
}
