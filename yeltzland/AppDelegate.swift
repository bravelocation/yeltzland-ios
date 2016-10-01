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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Nav bar colors
        UINavigationBar.appearance().barTintColor = AppColors.NavBarColor;

        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: AppColors.NavBarTextColor,
            NSFontAttributeName: UIFont(name: AppColors.AppFontName, size: AppColors.NavBarTextSize)!
        ]
        
        // Tab bar font
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: AppColors.AppFontName, size: AppColors.TabBarTextSize)!
        ], forState: .Normal)
        
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
        if launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
            GameSettings.instance.lastSelectedTab = 3
        } else if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] {
            self.handleShortcut(shortcutItem as! UIApplicationShortcutItem)
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let initialTabViewController = MainTabBarController()
        self.window?.rootViewController = initialTabViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("In background refresh ...")
        let now = NSDate()
        
        let differenceInMinutes = NSCalendar.currentCalendar().components(.Minute, fromDate: now, toDate: GameSettings.instance.nextGameTime, options: []).minute
        
        if (differenceInMinutes < 0) {
            // After game kicked off, so go get game score
            GameScoreManager.instance.getLatestGameScore()
            FixtureManager.instance.getLatestFixtures()
        
            completionHandler(UIBackgroundFetchResult.NewData)
        } else {
            // Otherwise, make sure the watch is updated occasionally
            GameSettings.instance.forceBackgroundWatchUpdate()
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        print("3D Touch when from shortcut action");
        let handledShortCut = self.handleShortcut(shortcutItem)
        
        // Reset selected tab
        let mainViewController: MainTabBarController? = self.window?.rootViewController as? MainTabBarController
        if (mainViewController != nil) {
            mainViewController!.selectedIndex = GameSettings.instance.lastSelectedTab
        }
        
        return completionHandler(handledShortCut);
    }
        
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if let window = self.window {
            window.rootViewController?.restoreUserActivityState(userActivity)
        }
        
        return true
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
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
 
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.azureNotifications.register(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ")
        print(error.description)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        self.messageReceived(application, userInfo: userInfo)
    }
    
    func application(application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                                                   fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        self.messageReceived(application, userInfo: userInfo)
        handler(UIBackgroundFetchResult.NoData);
    }
    
    func messageReceived(application: UIApplication,
                         userInfo: [NSObject : AnyObject]) {
        // Print message
        print("Notification received: \(userInfo)")
        
        // Go and update the game score
        GameScoreManager.instance.getLatestGameScore()
        
        // If app in foreground, show a toast
        if (application.applicationState == .Active) {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let body = alert["body"] as? NSString {
                        
                        // Show and hide a message after delay
                        if (self.window != nil && self.window?.rootViewController != nil) {
                            if let tabController : UITabBarController? = (self.window?.rootViewController as! UITabBarController) {
                                if let navigationController : UINavigationController? = tabController!.viewControllers![0] as? UINavigationController {
                                    MakeToast.Show(navigationController!.view!, message: body as String, delay: 5.0)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

