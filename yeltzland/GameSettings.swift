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

public class GameSettings : BaseSettings, WCSessionDelegate {

    private static let sharedInstance = GameSettings()
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Removed notification handler in game settings")
    }
    
    private func setupNotificationWatchers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameSettings.refreshFixtures), name: FixtureManager.FixturesNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameSettings.refreshGameScore), name: GameScoreManager.GameScoreNotification, object: nil)
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
            let session: WCSession = WCSession.defaultSession();
            session.delegate = self
            session.activateSession()
            print("Watch session activated")
        } else {
            print("No watch session set up")
        }
    }
    
    // Update the watch in background
    public func forceBackgroundWatchUpdate() {
        self.pushAllSettingsToWatch(false)
    }
    
    /// Send initial settings to watch
    override public func pushAllSettingsToWatch(currentlyInGame:Bool) {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            
            var updatedSettings = Dictionary<String, AnyObject>()
            updatedSettings["lastGameTime"] = self.lastGameTime
            updatedSettings["lastGameTeam"] = self.lastGameTeam
            updatedSettings["lastGameYeltzScore"] = self.lastGameYeltzScore
            updatedSettings["lastGameOpponentScore"] = self.lastGameOpponentScore
            updatedSettings["lastGameHome"] = self.lastGameHome
            
            updatedSettings["nextGameTime"] = self.nextGameTime
            updatedSettings["nextGameTeam"] = self.nextGameTeam
            updatedSettings["nextGameHome"] = self.nextGameHome
            
            updatedSettings["currentGameTime"] = self.currentGameTime
            updatedSettings["currentGameYeltzScore"] = self.currentGameYeltzScore
            updatedSettings["currentGameOpponentScore"] = self.currentGameOpponentScore
            
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
    public func session(session: WCSession,
                         activationDidCompleteWithState activationState: WCSessionActivationState,
                                                        error: NSError?) {}
    
    @objc
    public func sessionDidBecomeInactive(session: WCSession) {}
    
    @objc
    public func sessionDidDeactivate(session: WCSession) {}
}
