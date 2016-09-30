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

public class WatchGameSettings : BaseSettings, WCSessionDelegate {

    private static let sharedInstance = WatchGameSettings()
    class var instance:WatchGameSettings {
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
        print("Removed notification handler in watch game settings")
    }
    
    private func setupNotificationWatchers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WatchGameSettings.refreshFixtures), name: FixtureManager.FixturesNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WatchGameSettings.refreshGameScore), name: GameScoreManager.GameScoreNotification, object: nil)
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
            let session: WCSession = WCSession.defaultSession();
            session.delegate = self
            session.activateSession()
            print("Watch session activated")
        } else {
            print("No watch session set up")
        }
    }

    // MARK:- WCSessionDelegate implementation - update local settings when transfered from phone
    @objc
    public func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("New user info transfer data received on watch")
        self.updateSettings(userInfo)
    }
    
    @objc
    public func session(session: WCSession, didReceiveUpdate receivedApplicationContext: [String : AnyObject]) {
        print("New context transfer data received on watch")
        self.updateSettings(receivedApplicationContext)
    }
    
    @objc
    public func session(session: WCSession,
                        activationDidCompleteWithState activationState: WCSessionActivationState,
                        error: NSError?) {}
    
    @objc
    public func sessionDidBecomeInactive(session: WCSession) {}
    
    @objc
    public func sessionDidDeactivate(session: WCSession) {}
    
    private func updateSettings(userInfo: [String : AnyObject]) {
        // Update each incoming setting
        for (key, value) in userInfo {
            self.writeObjectToStore(value, key: key)
        }
        
        // Send a notification for the view controllers to refresh
        NSNotificationCenter.defaultCenter().postNotificationName(BaseSettings.SettingsUpdateNotification, object:nil, userInfo:nil)
        print("Sent 'Update Settings' notification")
    }
}

