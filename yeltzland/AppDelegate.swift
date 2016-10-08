//
//  AppDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let azureNotifications = AzureNotifications()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Nav bar colors
        UINavigationBar.appearance().barTintColor = AppColors.NavBarColor;

        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: AppColors.NavBarTextColor,
            NSFontAttributeName: UIFont(name: AppColors.AppFontName, size: AppColors.NavBarTextSize)!
        ]
        
        // Tab bar font
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: AppColors.AppFontName, size: AppColors.TabBarTextSize)!
        ], for: UIControlState())
        
        // Setup Fabric
        #if DEBUG
            Fabric.with([Twitter.self])
        #else
            Fabric.with([Crashlytics.self, Twitter.self])
        #endif
        
        // Setup notifications
        self.azureNotifications.setupNotifications(false)
        
        // Update the fixture and game score caches
        FixtureManager.instance.getLatestFixtures()
        GameScoreManager.instance.getLatestGameScore()
        
        // Setup backhground fetch
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        // Push settings to watch in the background
        GameSettings.instance.forceBackgroundWatchUpdate()
        
        // If came from a notification, always start on the Twitter tab
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            GameSettings.instance.lastSelectedTab = 3
        } else if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] {
            let result = self.handleShortcut(shortcutItem as! UIApplicationShortcutItem)
            print("Opened via shortcut: \(result)")
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let initialTabViewController = MainTabBarController()
        self.window?.rootViewController = initialTabViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("In background refresh ...")
        let now = Date()
        
        let differenceInMinutes = (Calendar.current as NSCalendar).components(.minute, from: now, to: GameSettings.instance.nextGameTime as Date, options: []).minute
        
        if (differenceInMinutes! < 0) {
            // After game kicked off, so go get game score
            GameScoreManager.instance.getLatestGameScore()
            FixtureManager.instance.getLatestFixtures()
        
            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            // Otherwise, make sure the watch is updated occasionally
            GameSettings.instance.forceBackgroundWatchUpdate()
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("3D Touch when from shortcut action");
        let handledShortCut = self.handleShortcut(shortcutItem)
        
        // Reset selected tab
        let mainViewController: MainTabBarController? = self.window?.rootViewController as? MainTabBarController
        if (mainViewController != nil) {
            mainViewController!.selectedIndex = GameSettings.instance.lastSelectedTab
        }
        
        return completionHandler(handledShortCut);
    }
        
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let window = self.window {
            window.rootViewController?.restoreUserActivityState(userActivity)
        }
        
        return true
    }
    
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        print("Handling shortcut item %@", shortcutItem.type);
        
        if (shortcutItem.type == "com.bravelocation.yeltzland.forum") {
            GameSettings.instance.lastSelectedTab = 0
            return true
        }
        
        if (shortcutItem.type == "com.bravelocation.yeltzland.official") {
            GameSettings.instance.lastSelectedTab = 1
            return true
        }
        
        if (shortcutItem.type == "com.bravelocation.yeltzland.yeltztv") {
            GameSettings.instance.lastSelectedTab = 2
            return true
        }
        
        if (shortcutItem.type == "com.bravelocation.yeltzland.twitter") {
            GameSettings.instance.lastSelectedTab = 3
            return true
        }
        
        return false
    }
 
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.azureNotifications.register(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")

        let tokenError = error as NSError
        print(tokenError.description)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.messageReceived(application, userInfo: userInfo)
    }
    
    func application(_ application: UIApplication,
                      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                                                   fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.messageReceived(application, userInfo: userInfo)
        handler(UIBackgroundFetchResult.noData);
    }
    
    func messageReceived(_ application: UIApplication,
                         userInfo: [AnyHashable: Any]) {
        // Print message
        print("Notification received: \(userInfo)")
        
        // Go and update the game score
        GameScoreManager.instance.getLatestGameScore()
        
        // If app in foreground, show a toast
        if (application.applicationState == .active) {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let body = alert["body"] as? NSString {
                        
                        // Show and hide a message after delay
                        if (self.window != nil && self.window?.rootViewController != nil) {
                            let tabController : UITabBarController? = (self.window?.rootViewController as! UITabBarController)
                            let navigationController : UINavigationController? = tabController!.viewControllers![0] as? UINavigationController
                            MakeToast.Show(navigationController!.view!, message: body as String, delay: 5.0)
                        }
                    }
                }
            }
        }
    }
}

