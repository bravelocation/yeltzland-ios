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

open class GameSettings : BaseSettings, WCSessionDelegate {

    fileprivate static let sharedInstance = GameSettings()
    class var instance:GameSettings {
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
        NotificationCenter.default.addObserver(self, selector: #selector(GameSettings.refreshFixtures), name: NSNotification.Name(rawValue: FixtureManager.FixturesNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameSettings.refreshGameScore), name: NSNotification.Name(rawValue: GameScoreManager.GameScoreNotification), object: nil)
        print("Setup notification handlers for fixture or score updates in game settings")
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
            let session: WCSession = WCSession.default();
            session.delegate = self
            session.activate()
            print("Watch session activated")
        } else {
            print("No watch session set up")
        }
    }
    
    // Update the watch in background
    open func forceBackgroundWatchUpdate() {
        self.pushAllSettingsToWatch(false)
    }
    
    /// Send initial settings to watch
    override open func pushAllSettingsToWatch(_ currentlyInGame:Bool) {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            
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
    
    // MARK:- WCSessionDelegate implementation
    @objc
    open func session(_ session: WCSession,
                         activationDidCompleteWith activationState: WCSessionActivationState,
                                                        error: Error?) {}
    
    @objc
    open func sessionDidBecomeInactive(_ session: WCSession) {}
    
    @objc
    open func sessionDidDeactivate(_ session: WCSession) {}
}
