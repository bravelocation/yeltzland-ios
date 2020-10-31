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
                if window.traitCollection.userInterfaceIdiom == .pad {
                    if let splitViewController = createTwoColumnSplitViewController(tabController) {
                        initialController = splitViewController
                    }
                }
            }
            
            if initialController == nil {
                initialController = tabController
                
                if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
                    initialController!.restoreUserActivityState(userActivity)
                }
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

@available(iOS 14, *)
extension SceneDelegate {
    private func createTwoColumnSplitViewController(_ tabController: MainTabBarController) -> UISplitViewController? {
        // TODO(JP): get this from navigation manager
        let webViewController = WebPageViewController()
        webViewController.homeUrl = URL(string: "https://yeltz.co.uk")!
        webViewController.pageTitle = "Yeltz Forum"
        let navViewController = UINavigationController(rootViewController: webViewController)
        
        let sidebarViewController = SidebarViewController()

        let splitViewController = UISplitViewController(style: .doubleColumn)
        splitViewController.primaryBackgroundStyle = .sidebar
        splitViewController.preferredDisplayMode = .oneBesideSecondary

        splitViewController.setViewController(sidebarViewController, for: .primary)
        splitViewController.setViewController(navViewController, for: .secondary)
        splitViewController.setViewController(tabController, for: .compact)
        
        // Set color of expand button and expanders
        splitViewController.view.tintColor = UIColor.white
        
        return splitViewController
    }
}
