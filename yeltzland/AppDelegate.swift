//
//  AppDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import BackgroundTasks
import Firebase
import Intents
import WebKit
import WidgetKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Application properties
    var window: UIWindow?
    var firebaseNotifications: FirebaseNotifications?
    var processPool: WKProcessPool = WKProcessPool()
    let navigationManager = NavigationManager()
    
    // MARK: - UIApplicationDelegate functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Nav bar colors
        UINavigationBar.appearance().barTintColor = UIColor(named: "yeltz-blue")

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

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
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bravelocation.yeltzland.backgroundRefresh", using: nil) { (task) in
              self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
            }
        } else {
            application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        }
        
        // Push settings to watch in the background
        GameSettings.shared.forceBackgroundWatchUpdate()
        
        if #available(iOS 13.0, *) {
            // Window initialisation will be handled by the scene delegate in iOS 13+
        } else {
            // Calculate the correct user activity to pre-populate the selected tab
            var startingActivity = NSUserActivity(activityType: "com.bravelocation.yeltzland.navigation")
            
            // Restore any incoming user activity info
            if let activityType = launchOptions?[UIApplication.LaunchOptionsKey.userActivityType] as? String {
                startingActivity = NSUserActivity(activityType: activityType)
                
                if let activityInfo = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] {
                    startingActivity.userInfo = activityInfo
                }
            }
            
            // If came from a shortcut
            if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] {
                let navActivity = self.navigationManager.handleShortcut(shortcutItem as! UIApplicationShortcutItem)
                startingActivity.userInfo = navActivity.userInfo
            }
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let initialTabViewController = MainTabBarController()
            initialTabViewController.restoreUserActivityState(startingActivity)
            
            self.window?.rootViewController = initialTabViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("3D Touch when from shortcut action")
        let startingActivity = NSUserActivity(activityType: "com.bravelocation.yeltzland.navigation")
        startingActivity.userInfo = self.navigationManager.handleShortcut(shortcutItem).userInfo

        // Reset selected tab
        if let mainViewController = self.window?.rootViewController as? MainTabBarController {
            mainViewController.restoreUserActivityState(startingActivity)
        } else if let mainSplitViewController = self.window?.rootViewController as? MainSplitViewController {
            mainSplitViewController.restoreUserActivityState(startingActivity)
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
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        // Print message
        print("Notification received: \(userInfo)")
        
        Messaging.messaging().appDidReceiveMessage(response.notification.request.content.userInfo)
        
        // Go and update the game score and fixtures, and update widgets
        GameScoreManager.shared.fetchLatestData(completion: nil)
        FixtureManager.shared.fetchLatestData(completion: nil)
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }

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

// MARK: - Background refresh logic
extension AppDelegate {
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let newDataFetched = self.appRefresh()
        if newDataFetched {
            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    @available(iOS 13.0, *)
    func handleAppRefreshTask(task: BGAppRefreshTask) {
        _ = self.appRefresh()
        
        task.expirationHandler = {} // Nothing to do on expiration
    }
    
    @available(iOS 13.0, *)
    func scheduleBackgroundFetch() {
        print("Scheduling background task ...")
        
        let fixtureDataFetchTask = BGAppRefreshTaskRequest(identifier: "com.bravelocation.yeltzland.backgroundRefresh")
        fixtureDataFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        do {
          try BGTaskScheduler.shared.submit(fixtureDataFetchTask)
        } catch {
          print("Unable to submit background task: \(error.localizedDescription)")
        }
    }
    
    // Handles app refresh logic - retturns true if we fetched new data
    private func appRefresh() -> Bool {
        print("In background refresh ...")
        let now = Date()
        
        if let nextGame = FixtureManager.shared.nextGame {
            if let differenceInMinutes = (Calendar.current as NSCalendar).components(.minute, from: now, to: nextGame.fixtureDate, options: []).minute {
                if (differenceInMinutes < 0) {
                    // After game kicked off, so go get game score and update widgets
                    GameScoreManager.shared.fetchLatestData() { result in
                        if result == .success(true) {
                            FixtureManager.shared.fetchLatestData() { result in
                                if result == .success(true) {
                                    if #available(iOS 14.0, *) {
                                        WidgetCenter.shared.reloadAllTimelines()
                                    }
                                }
                            }
                        }
                    }
                    
                    return true
                }
            }
        }
        
        // Otherwise, make sure the watch is updated occasionally
        GameSettings.shared.forceBackgroundWatchUpdate()
        return false
    }
}
