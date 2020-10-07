//
//  SceneDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 10/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let initialTabViewController = MainTabBarController()
            
            if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
                initialTabViewController.restoreUserActivityState(userActivity)
            }
            
            window.rootViewController = initialTabViewController
            self.window = window
            window.makeKeyAndVisible()
            
            #if targetEnvironment(macCatalyst) 
            if let titlebar = windowScene.titlebar {
                titlebar.titleVisibility = .hidden
                titlebar.toolbar = nil
            }
            #endif
        }
    }
    
    @available(iOS 13.0, *)
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let window = self.window {
            window.rootViewController?.restoreUserActivityState(userActivity)
        }
    }
    
    @available(iOS 13.0, *)
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("3D Touch when from shortcut action")
        let startingActivity = NSUserActivity(activityType: "com.bravelocation.yeltzland.currenttab")
        startingActivity.userInfo = [:]
        startingActivity.userInfo?["com.bravelocation.yeltzland.currenttab.key"] = self.handleShortcut(shortcutItem)
        
        // Reset selected tab
        if let mainViewController = self.window?.rootViewController as? MainTabBarController {
            mainViewController.restoreUserActivityState(startingActivity)
        }
        
        return completionHandler(true)
    }
    
    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as! AppDelegate).scheduleBackgroundFetch()
    }
    
    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("In scene enter foreground ...")

        GameScoreManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                FixtureManager.shared.fetchLatestData() { result in
                    if result == .success(true) {
                        if #available(iOS 14.0, *) {
                            #if !targetEnvironment(macCatalyst)
                            WidgetCenter.shared.reloadAllTimelines()
                            #endif
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private functions
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Int {
        print("Handling shortcut item %@", shortcutItem.type)
        
        switch shortcutItem.type {
        case "com.bravelocation.yeltzland.forum":
            return 0
        case "com.bravelocation.yeltzland.official":
            return 1
        case "com.bravelocation.yeltzland.yeltztv":
            return 2
        case "com.bravelocation.yeltzland.twitter":
            return 3
        default:
            return 0
        }
    }
}
