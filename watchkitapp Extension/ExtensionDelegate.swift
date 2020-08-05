//
//  ExtensionDelegate.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import WatchKit
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var backgroundTaskSetup = false
    
    override init() {
        super.init()
        self.setupNotificationWatchers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Removed notification handler in watch extension delegate")
    }
    
    fileprivate func setupNotificationWatchers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ExtensionDelegate.settingsUpdated), name: NSNotification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
        print("Setup notification handlers for settings updates in extension delegate")
    }

    func applicationDidBecomeActive() {
        print("Application did become active")
        WatchGameSettings.shared.initialiseWatchSession()
        
        if (self.backgroundTaskSetup == false) {
            self.setupBackgroundRefresh()
            
            // Go and fetch the latest data in the background
            FixtureManager.shared.fetchLatestData(completion: nil)
            GameScoreManager.shared.fetchLatestData(completion: nil)
        }
        
        // Always force a complication update if you open the app
        self.settingsUpdated()
    }
 
    func setupBackgroundRefresh() {       
        let globalCalendar = Calendar.autoupdatingCurrent
        let now = Date()

        // Setup a background refresh based on game state
        var backgroundRefreshMinutes = 6 * 60
        
        // Find the next fixture to use
        var latestFixture: Fixture? = FixtureManager.shared.lastGame
        
        if let currentFixture = GameScoreManager.shared.currentFixture {
            if currentFixture.inProgress {
                latestFixture = currentFixture
            }
        }
        
        // If the next fixture is missing or too far away, get next game
        if latestFixture == nil || latestFixture!.state == .manyDaysAfter {
            latestFixture = FixtureManager.shared.nextGame
        }
        
        if let fixture = latestFixture {
            switch (fixture.state) {
            case .gameDayBefore:
                // Calculate minutes to start of the game
                var minutesToGameStart = (globalCalendar as NSCalendar).components([.minute], from: now, to: fixture.fixtureDate as Date, options: []).minute ?? 0
                
                if (minutesToGameStart <= 0) {
                    minutesToGameStart = 60
                }
                
                backgroundRefreshMinutes = minutesToGameStart
            case .during:
                backgroundRefreshMinutes = 15;          // Every 15 mins during the game
            case .after:
                backgroundRefreshMinutes = 60;          // Every hour after the game
            default:
                backgroundRefreshMinutes = 6 * 60;      // Otherwise, every 6 hours
            }
        }

        let nextRefreshTime = (globalCalendar as NSCalendar).date(byAdding: .minute, value: backgroundRefreshMinutes, to: now, options: [])
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: nextRefreshTime!, userInfo: nil, scheduledCompletion: self.backgroundRefreshRunning)
        
        print("Setup background task for \(nextRefreshTime!)")
        self.backgroundTaskSetup = true
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Handling background task started")
        
        // Mark tasks as completed
        for task in backgroundTasks {
            // If it was a background task, update complications and setup a new one
            if (task is WKApplicationRefreshBackgroundTask) {
                
                // Go and fetch the latest data
                FixtureManager.shared.fetchLatestData(completion: nil)
                GameScoreManager.shared.fetchLatestData(completion: nil)
                
                // Setup next background refresh
                self.setupBackgroundRefresh()
                
                // Always force a complication update on a background refresh
                self.settingsUpdated()
            }
            
            // Take a snapshot (unless this was a snapshot refresh task itself!)
            let snapshotTaken = task is WKSnapshotRefreshBackgroundTask
            task.setTaskCompletedWithSnapshot(!snapshotTaken)
        }
    }
    
    @objc func settingsUpdated() {
        // Update complications
        print("Updating complications...")
        let complicationServer = CLKComplicationServer.sharedInstance()
        let activeComplications = complicationServer.activeComplications
        
        if (activeComplications != nil) {
            for complication in activeComplications! {
                complicationServer.reloadTimeline(for: complication)
            }
        }
        print("Complications updated")
        
        // Schedule snapshot
        print("Scheduling snapshot")
        let soon =  (Calendar.autoupdatingCurrent as NSCalendar).date(byAdding: .second, value: 5, to: Date(), options: [])
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: soon!, userInfo: nil, scheduledCompletion: self.backgroundRefreshRunning)
        print("Snapshot scheduled")
    }
    
    private func backgroundRefreshRunning(error: Error?) {
        if (error != nil) {
            print("Error running background task: \(error.debugDescription)")
        }
    }
}
