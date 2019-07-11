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

    // MARK: Application properties
    var window: UIWindow?
    var firebaseNotifications: FirebaseNotifications?
    
    // MARK: - UIApplicationDelegate functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Nav bar colors
        UINavigationBar.appearance().barTintColor = UIColor(named: "yeltz-blue")

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: AppFonts.AppFontName, size: AppFonts.NavBarTextSize)!
        ]
        
        // Setup Twitter not via Fabric
        let twitterConsumerKey = SettingsManager.shared.getSetting("TwitterConsumerKey") as! String
        let twitterConsumerSecret = SettingsManager.shared.getSetting("TwitterConsumerSecret") as! String

        TWTRTwitter.sharedInstance().start(withConsumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)

        // Setup notifications
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        
        // Must be done after FirebaseApp.configure() according to https://github.com/firebase/firebase-ios-sdk/issues/2240
        self.firebaseNotifications = FirebaseNotifications()
        self.firebaseNotifications?.setupNotifications(false)
        
        // Update the fixture and game score caches
        FixtureManager.shared.fetchLatestData(completion: nil)
        GameScoreManager.shared.fetchLatestData(completion: nil)
        
        // Setup background fetch
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // Push settings to watch in the background
        GameSettings.shared.forceBackgroundWatchUpdate()
        
        // Donate all the shortcuts
        if #available(iOS 12.0, *) {
            ShortcutManager.shared.donateAllShortcuts()
        }
        
        if #available(iOS 13.0, *) {
            // Window initialisation will be handled by the scene delegate in iOS 13+
        } else {
            
            // Calculate the correct user activity to pre-populate the selected tab
            let startingActivity = NSUserActivity(activityType: "com.bravelocation.yeltzland.currenttab")
            startingActivity.userInfo = [:]
            startingActivity.userInfo?["com.bravelocation.yeltzland.currenttab.key"] = GameSettings.shared.lastSelectedTab
            
            // If came from a shortcut
            if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] {
                startingActivity.userInfo?["com.bravelocation.yeltzland.currenttab.key"] =  self.handleShortcut(shortcutItem as! UIApplicationShortcutItem)
            }
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let initialTabViewController = MainTabBarController()
            initialTabViewController.restoreUserActivityState(startingActivity)
            
            self.window?.rootViewController = initialTabViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("In background refresh ...")
        let now = Date()
        
        if let nextGame = FixtureManager.shared.nextGame {
            if let differenceInMinutes = (Calendar.current as NSCalendar).components(.minute, from: now, to: nextGame.fixtureDate, options: []).minute {
                if (differenceInMinutes < 0) {
                    // After game kicked off, so go get game score
                    GameScoreManager.shared.fetchLatestData(completion: nil)
                    FixtureManager.shared.fetchLatestData(completion: nil)
                    
                    completionHandler(UIBackgroundFetchResult.newData)
                    return
                }
            }
        }
        
        // Otherwise, make sure the watch is updated occasionally
        GameSettings.shared.forceBackgroundWatchUpdate()
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
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
        
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let window = self.window {
            window.rootViewController?.restoreUserActivityState(userActivity)
        }
        
        return true
    }
 
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.firebaseNotifications?.register(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")

        let tokenError = error as NSError
        print(tokenError.description)
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

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        // Print message
        print("Notification received: \(userInfo)")
        
        Messaging.messaging().appDidReceiveMessage(response.notification.request.content.userInfo)
        
        // Go and update the game score and fixtures
        GameScoreManager.shared.fetchLatestData(completion: nil)
        FixtureManager.shared.fetchLatestData(completion: nil)

        // If app in foreground, show a toast
        if (UIApplication.shared.applicationState == .active) {
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
        
        completionHandler()
    }
}
