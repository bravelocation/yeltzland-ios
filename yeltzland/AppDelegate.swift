//
//  AppDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import TwitterKit
import Firebase
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let firebaseNotifications = FirebaseNotifications()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Nav bar colors
        UINavigationBar.appearance().barTintColor = AppColors.NavBarColor

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: AppColors.NavBarTextColor,
            NSAttributedString.Key.font: UIFont(name: AppColors.AppFontName, size: AppColors.NavBarTextSize)!
        ]
        
        // Setup Twitter not via Fabric
        let twitterConsumerKey = SettingsManager.instance.getSetting("TwitterConsumerKey") as! String
        let twitterConsumerSecret = SettingsManager.instance.getSetting("TwitterConsumerSecret") as! String

        TWTRTwitter.sharedInstance().start(withConsumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)

        // Setup notifications
        FirebaseApp.configure()
        self.firebaseNotifications.setupNotifications(false)
        
        // Update the fixture and game score caches
        FixtureManager.instance.getLatestFixtures()
        GameScoreManager.instance.getLatestGameScore()
        
        // Setup background fetch
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // Push settings to watch in the background
        GameSettings.instance.forceBackgroundWatchUpdate()
        
        // Donate all the shortcuts
        if #available(iOS 12.0, *) {
            ShortcutManager.instance.donateAllShortcuts()
        }
        
        // If came from a notification, always start on the Twitter tab
        if launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
            GameSettings.instance.lastSelectedTab = 3
        } else if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] {
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
        
        if let nextGame = FixtureManager.instance.getNextGame() {
            if let differenceInMinutes = (Calendar.current as NSCalendar).components(.minute, from: now, to: nextGame.fixtureDate, options: []).minute {
                if (differenceInMinutes < 0) {
                    // After game kicked off, so go get game score
                    GameScoreManager.instance.getLatestGameScore()
                    FixtureManager.instance.getLatestFixtures()
                    
                    completionHandler(UIBackgroundFetchResult.newData)
                    return
                }
            }
        }
        
        // Otherwise, make sure the watch is updated occasionally
        GameSettings.instance.forceBackgroundWatchUpdate()
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("3D Touch when from shortcut action")
        let handledShortCut = self.handleShortcut(shortcutItem)
        
        // Reset selected tab
        if let mainViewController = self.window?.rootViewController as? MainTabBarController {
            mainViewController.selectedIndex = GameSettings.instance.lastSelectedTab
        }
        
        return completionHandler(handledShortCut)
    }
        
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let window = self.window {
            window.rootViewController?.restoreUserActivityState(userActivity)
        }
        
        return true
    }
    
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        print("Handling shortcut item %@", shortcutItem.type)
        
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
        self.firebaseNotifications.register(deviceToken)
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
        handler(UIBackgroundFetchResult.noData)
    }
    
    func messageReceived(_ application: UIApplication,
                         userInfo: [AnyHashable: Any]) {
        // Print message
        print("Notification received: \(userInfo)")
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Go and update the game score and fixtures
        GameScoreManager.instance.getLatestGameScore()
        FixtureManager.instance.getLatestFixtures()
        
        // If app in foreground, show a toast
        if (application.applicationState == .active) {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let body = alert["body"] as? NSString {
                        
                        // Show and hide a message after delay
                        if (self.window != nil && self.window?.rootViewController != nil) {
                            let tabController: UITabBarController? = (self.window?.rootViewController as! UITabBarController)
                            let navigationController: UINavigationController? = tabController!.viewControllers![0] as? UINavigationController
                            MakeToast.show(navigationController!, title: "Alert", message: body as String)
                        }
                    }
                }
            }
        }
    }
}
