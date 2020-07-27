//
//  GameSettings.swift
//  yeltzland
//
//  Created by John Pollard on 28/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

public class GameSettings: BaseSettings, WCSessionDelegate {

    private static let sharedInstance = GameSettings()
    
    class var shared: GameSettings {
        get {
            return sharedInstance
        }
    }

    public override init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.yeltzland") {
        super.init(defaultPreferencesName: defaultPreferencesName, suiteName: suiteName)
        self.setupNotificationWatchers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Removed notification handler in game settings")
    }
    
    fileprivate func setupNotificationWatchers() {
        NotificationCenter.default.addObserver(self, selector: #selector(GameSettings.fixturesUpdated), name: .FixturesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameSettings.gameScoresUpdated), name: .GameScoreUpdated, object: nil)
        print("Setup notification handlers for fixture or score updates in game settings")
    }
    
    @objc fileprivate func fixturesUpdated() {
        GameScoreManager.shared.fetchLatestData(completion: nil)
        self.updateLatestScoreSettings()
    }
    
    @objc fileprivate func gameScoresUpdated() {
        self.updateLatestScoreSettings()
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
    
    // Update the watch in background
    public func forceBackgroundWatchUpdate() {
        self.pushAllSettingsToWatch(false)
    }
    
    /// Send settings to watch
    override public func pushAllSettingsToWatch(_ currentlyInGame: Bool) {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            
            var updatedSettings = Dictionary<String, AnyObject>()
            updatedSettings["currentGameTime"] = self.currentGameTime as AnyObject?
            updatedSettings["currentGameYeltzScore"] = self.currentGameYeltzScore as AnyObject?
            updatedSettings["currentGameOpponentScore"] = self.currentGameOpponentScore as AnyObject?
            
            // If we're in a game, push it out straight away, otherwise do it in the background
            // When upgraded to iOS10 target, we can also check for session.remainingComplicationUserInfoTransfers > 0
            if (currentlyInGame) {
                session.transferCurrentComplicationUserInfo(updatedSettings)
            } else {
                session.transferUserInfo(updatedSettings)
            }
            
            print("Settings pushed to watch")
        }
    }
    
    // MARK: - WCSessionDelegate implementation
    @objc
    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {}
    
    @objc
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    
    @objc
    public func sessionDidDeactivate(_ session: WCSession) {}
}
