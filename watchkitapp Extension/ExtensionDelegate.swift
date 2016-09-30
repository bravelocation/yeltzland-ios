//
//  ExtensionDelegate.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    override init() {
        super.init()
        self.setupNotificationWatchers()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Removed notification handler in watch extension delegate")
    }
    
    private func setupNotificationWatchers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ExtensionDelegate.settingsUpdated), name: BaseSettings.SettingsUpdateNotification, object: nil)
        print("Setup notification handlers for settings updates in extension delegate")
    }

    func applicationDidBecomeActive() {
        print("Application did become active")
        WatchGameSettings.instance.initialiseWatchSession()
        
        // Go and fetch the latest data
        FixtureManager.instance.getLatestFixtures()
        GameScoreManager.instance.getLatestGameScore()
        
        self.setupBackgroundRefresh()
    }
 
    func setupBackgroundRefresh() {
        let globalCalendar = NSCalendar.autoupdatingCurrentCalendar()
        let now = NSDate()

        // Setup a background refresh based on game state
        var backgroundRefreshMinutes = 6 * 60;
        
        let gameState = WatchGameSettings.instance.currentGameState()
        switch (gameState) {
            case .GameDayBefore:
                // Calculate minutes to start of the game
                var minutesToGameStart = globalCalendar.components([.Minute], fromDate: now, toDate: WatchGameSettings.instance.nextGameTime, options: []).minute ?? 0
                
                if (minutesToGameStart <= 0) {
                    minutesToGameStart = 60;
                }

                backgroundRefreshMinutes = minutesToGameStart;
            case .During, .DuringNoScore:
                backgroundRefreshMinutes = 15;          // Every 15 mins during the game
            case .After:
                backgroundRefreshMinutes = 60;          // Every hour after the game
            default:
                backgroundRefreshMinutes = 6 * 60;      // Otherwise, every 6 hours
        }
        
        let nextRefreshTime = globalCalendar.dateByAddingUnit(.Minute, value: backgroundRefreshMinutes, toDate: now, options: [])
        
        WKExtension.sharedExtension().scheduleBackgroundRefreshWithPreferredDate(nextRefreshTime!, userInfo: nil, scheduledCompletion: { (error: NSError?) in
            if let error = error {
                print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
            }
        })
        
        print("Setup background task for \(nextRefreshTime)")
    }

    
    func handleBackgroundTasks(backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Handling background task started")
        
        // Mark tasks as completed
        for task in backgroundTasks {
            // If it was a background task, update complications and setup a new one
            if (task is WKApplicationRefreshBackgroundTask) {
                
                // Go and fetch the latest data
                FixtureManager.instance.getLatestFixtures()
                GameScoreManager.instance.getLatestGameScore()
                
                // Setup next background refresh
                self.setupBackgroundRefresh()
            }
            
            task.setTaskCompleted()
        }
    }
    
    func settingsUpdated() {
        // Update complications
        print("Updating complications...")
        let complicationServer = CLKComplicationServer.sharedInstance()
        let activeComplications = complicationServer.activeComplications
        
        if (activeComplications != nil) {
            for complication in activeComplications! {
                complicationServer.reloadTimelineForComplication(complication)
            }
        }
        print("Complications updated")
        
        // Schedule snapshot
        print("Scheduling snapshot")
        let soon =  NSCalendar.autoupdatingCurrentCalendar().dateByAddingUnit(.Second, value: 5, toDate: NSDate(), options: [])
        WKExtension.sharedExtension().scheduleSnapshotRefreshWithPreferredDate(soon!, userInfo: nil, scheduledCompletion: { (error: NSError?) in
            if let error = error {
                print("Error occurred while scheduling snapshot: \(error.localizedDescription)")
            }})
        print("Snapshot scheduled")
    }
}
