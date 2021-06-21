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
        let tabBar = UITabBarController()
        tabBar.viewControllers = [articles(), markets()]
 
        window?.rootViewController = tabBar
    }
    
    private func articles() -> UIViewController {
        let url = URL(string: "https://content.dailyfx.com/api/v1/dashboard")!
        let remoteArticlesLoader = RemoteArticlesLoader(url: url, client: httpClient)
        let remoteImageLoader = RemoteImageDataLoader(client: httpClient)
        let factory = AppViewControllerFactory(imageLoader: remoteImageLoader)
        let articlesRouter = ArticlesRouter(factory: factory)
        
        let view = UINavigationController(
            rootViewController: ArticlesDashboardUIComposer.dashboardComposedWith(
                articlesLoader: remoteArticlesLoader,
                imageLoader: remoteImageLoader,
                router: articlesRouter))
        
        view.tabBarItem.title = "Articles"
        return view
    }
    
    private func markets() -> UIViewController {
        let url = URL(string: "https://content.dailyfx.com/api/v1/markets")!
        let marketsLoader = RemoteMarketsLoader(url: url, client: httpClient)
        let view = UINavigationController(
            rootViewController: MarketsUIComposer.dashboardComposedWith(marketsLoader: marketsLoader))
        view.tabBarItem.title = "Markets"
        return view
    }

}

