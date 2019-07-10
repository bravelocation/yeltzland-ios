//
//  SceneDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 10/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let initialTabViewController = MainTabBarController()
            
            var startingActivity = NSUserActivity(activityType: "com.bravelocation.yeltzland.currenttab")
            startingActivity.userInfo = [:]
            startingActivity.userInfo?["com.bravelocation.yeltzland.currenttab.key"] = GameSettings.shared.lastSelectedTab
            
            if session.stateRestorationActivity != nil {
                startingActivity = session.stateRestorationActivity!
            }
            
            initialTabViewController.restoreUserActivityState(startingActivity)
            
            window.rootViewController = initialTabViewController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
