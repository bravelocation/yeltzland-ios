//
//  WatchGameSettings.swift
//  yeltzland
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import WatchConnectivity
import ClockKit
import WatchKit

public class WatchGameSettings: BaseSettings, WCSessionDelegate {

    fileprivate static let sharedInstance = WatchGameSettings()
    class var shared: WatchGameSettings {
        get {
            return sharedInstance
        }
    }
    
    public override init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.yeltzland") {
        super.init(defaultPreferencesName: defaultPreferencesName, suiteName: suiteName)
        self.setupNotificationWatchers()
    }
    
    fileprivate func setupNotificationWatchers() {
        NotificationCenter.default.addObserver(self, selector: #selector(WatchGameSettings.updateLatestScoreSettings), name: .FixturesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WatchGameSettings.updateLatestScoreSettings), name: .GameScoreUpdated, object: nil)
        print("Setup notification handlers for fixture or score updates in watch game settings")
    }

    func initialiseWatchSession() {
        if (self.watchSessionInitialised) {
            print("Watch session already initialised")
            return
        }
        
        self.watchSessionInitialised = true
        print("Watch session starting initialisation...")
        
        // Set up watch setting if appropriate
        if (WCSession.isSupported()) {
            print("Setting up watch session ...")
            let session: WCSession = WCSession.default
            session.delegate = self
            session.activate()
            print("Watch session activated")
        } else {
            print("No watch session set up")
        }
    }

    // MARK: - WCSessionDelegate implementation - update local settings when transfered from phone
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        print("New user info transfer data received on watch")
        self.updateSettings(userInfo as [String: AnyObject])
    }
    
    @nonobjc public func session(_ session: WCSession, didReceiveUpdate receivedApplicationContext: [String: AnyObject]) {
        print("New context transfer data received on watch")
        self.updateSettings(receivedApplicationContext)
    }
    
    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {}
    
    private func updateSettings(_ userInfo: [String: AnyObject]) {
        // Update each incoming setting
        var gameSettingsUpdated = false

        for (key, value) in userInfo {
            switch (key) {
            case "currentGameTime":
                if (self.currentGameTime != (value as! Date)) {
                    gameSettingsUpdated = true
                }
            case "currentGameYeltzScore":
                if (self.currentGameYeltzScore != (value as! Int)) {
                    gameSettingsUpdated = true
                }
            case "currentGameOpponentScore":
                if (self.currentGameOpponentScore != (value as! Int)) {
                    gameSettingsUpdated = true
                }
            default:
                break
            }
        }
        
        // If we don't have the latest values, go and fetch them
        // If we store them directly, when we open the watch app after a long time we get lots of "updates" at once
        if (gameSettingsUpdated) {
            print("Game settings updating on watch after push phone")
            GameScoreManager.shared.fetchLatestData(completion: nil)
        }
    }
}
