//
//  AppDelegate.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import SwiftUI

@main
struct SwiftUIAppLifeCycleApp: App {
    
    //swiftlint:disable:next weak_delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            TVOSTabView()
                .environmentObject(self.tweetData)
                .environmentObject(FixtureData())
                .environmentObject(TimelineData())
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                // Update the fixture and game score caches when the app becomes active
                FixtureManager.shared.fetchLatestData(completion: nil)
                GameScoreManager.shared.fetchLatestData(completion: nil)
                
            case .inactive, .background:
                break
            @unknown default:
                print("Oh - interesting: I received an unexpected new value.")
            }
        }
    }
    
    var tweetData: TweetData {
        let twitterConsumerKey = SettingsManager.shared.getSetting("TwitterConsumerKey") as! String
        let twitterConsumerSecret = SettingsManager.shared.getSetting("TwitterConsumerSecret") as! String
        let twitterAccountName = "halesowentownfc"
        
        let twitterDataProvider = TwitterDataProvider(
            twitterConsumerKey: twitterConsumerKey,
            twitterConsumerSecret: twitterConsumerSecret,
            tweetCount: 20,
            accountName: twitterAccountName
        )
        
        return TweetData(dataProvider: twitterDataProvider, accountName: twitterAccountName)
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("In background refresh ...")
        let now = Date()
        
        if let nextGame = FixtureManager.shared.nextGame {
            if let differenceInMinutes = (Calendar.current as NSCalendar).components(.minute, from: now, to: nextGame.fixtureDate, options: []).minute {
                if (differenceInMinutes < 0) {
                    // After game kicked off, so go get game score
                    FixtureManager.shared.fetchLatestData(completion: nil)
                    GameScoreManager.shared.fetchLatestData(completion: nil)

                    completionHandler(UIBackgroundFetchResult.newData)
                    return
                }
            }
        }
        
        completionHandler(UIBackgroundFetchResult.noData)
    }
}
