//
//  SceneDelegate.swift
//  DailyFXFetchApp
//
//  Created by Mammadov, Mikayil on 20/06/2021.
//

import UIKit
import DailyFXFetchEngine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        self.window?.makeKeyAndVisible()
        configureWindow()
    }
    
    private func configureWindow() {
        let url = URL(string: "https://content.dailyfx.com/api/v1/dashboard")!
        let remoteArticlesLoader = RemoteArticlesLoader(url: url, client: httpClient)
        let remoteImageLoader = RemoteImageDataLoader(client: httpClient)
        let navigationController = UINavigationController()
        let factory = AppViewControllerFactory(httpClient: httpClient)
        let articlesRouter = ArticlesRouter(navigationController: navigationController, factory: factory)
        
        let view = ArticlesDashboardUIComposer.dashboardComposedWith(articlesLoader: remoteArticlesLoader, imageLoader: remoteImageLoader, router: articlesRouter)
        navigationController.setViewControllers([view], animated: true)
        
        window?.rootViewController = navigationController
    }

}

