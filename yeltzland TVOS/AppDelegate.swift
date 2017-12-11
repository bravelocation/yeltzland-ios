//
//  AppDelegate.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Update the fixture and game score caches
        FixtureManager.instance.getLatestFixtures()
        GameScoreManager.instance.getLatestGameScore()
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("In background refresh ...")
        let now = Date()
        let gameSettings = TVGameSettings()
        
        if let nextGameTime = gameSettings.nextGameTime
        {
            if let differenceInMinutes = (Calendar.current as NSCalendar).components(.minute, from: now, to: nextGameTime, options: []).minute
            {
                if (differenceInMinutes < 0) {
                    // After game kicked off, so go get game score
                    GameScoreManager.instance.getLatestGameScore()
                    FixtureManager.instance.getLatestFixtures()
                    
                    completionHandler(UIBackgroundFetchResult.newData)
                    return
                }
            }
        }
        
        completionHandler(UIBackgroundFetchResult.noData)
    }
}

