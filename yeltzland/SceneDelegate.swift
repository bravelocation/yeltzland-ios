//
//  SceneDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 10/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import UIKit
#if !targetEnvironment(macCatalyst)
import WidgetKit
#endif

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            var initialController: UIViewController?
            let tabController = MainTabBarController()
            
            // Try using the split bar view if appropriate
            if #available(iOS 14, *) {
                if window.traitCollection.userInterfaceIdiom == .pad || window.traitCollection.userInterfaceIdiom == .mac {
                    initialController = MainSplitViewController(tabController: tabController)
                    tabController.usedWithSplitViewController = true
                }
            }
            
            // Otherwise use the tab bar controller
            if initialController == nil {
                initialController = tabController
            }
            
            if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
                initialController!.restoreUserActivityState(userActivity)
            } else {
                // Calculate the correct user activity to pre-populate the selected tab
                let startingActivity = NSUserActivity(activityType: "com.bravelocation.yeltzland.navigation")
                
                let navigationManager = (UIApplication.shared.delegate as! AppDelegate).navigationManager
                startingActivity.userInfo = NavigationActivity(main: true, navElementId: navigationManager.mainSection.elements[0].id).userInfo
                initialController!.restoreUserActivityState(startingActivity)
            }
            
            window.rootViewController = initialController
            
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
        let navigationManager = (UIApplication.shared.delegate as! AppDelegate).navigationManager
        return navigationManager.lastUserActivity
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
        let startingActivity = NSUserActivity(activityType: "com.bravelocation.yeltzland.navigation")
        
        let navigationManager = (UIApplication.shared.delegate as! AppDelegate).navigationManager
        startingActivity.userInfo = navigationManager.handleShortcut(shortcutItem).userInfo
        
        // Reset selected window
        if let tabViewController = self.window?.rootViewController as? MainTabBarController {
            tabViewController.restoreUserActivityState(startingActivity)
        } else if let mainSplitViewController = self.window?.rootViewController as? MainSplitViewController {
            mainSplitViewController.restoreUserActivityState(startingActivity)
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
}
