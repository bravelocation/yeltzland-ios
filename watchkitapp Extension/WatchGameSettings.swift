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

open class WatchGameSettings : BaseSettings, WCSessionDelegate {

    fileprivate static let sharedInstance = WatchGameSettings()
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
        NotificationCenter.default.removeObserver(self)
        print("Removed notification handler in watch game settings")
    }
    
    fileprivate func setupNotificationWatchers() {
        NotificationCenter.default.addObserver(self, selector: #selector(WatchGameSettings.refreshFixtures), name: NSNotification.Name(rawValue: FixtureManager.FixturesNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WatchGameSettings.refreshGameScore), name: NSNotification.Name(rawValue: GameScoreManager.GameScoreNotification), object: nil)
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
            let session: WCSession = WCSession.default();
            session.delegate = self
            session.activate()
            print("Watch session activated")
        } else {
            print("No watch session set up")
        }
    }

    // MARK:- WCSessionDelegate implementation - update local settings when transfered from phone
    open func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        print("New user info transfer data received on watch")
        self.updateSettings(userInfo as [String : AnyObject])
    }
    
    @nonobjc open func session(_ session: WCSession, didReceiveUpdate receivedApplicationContext: [String : AnyObject]) {
        print("New context transfer data received on watch")
        self.updateSettings(receivedApplicationContext)
    }
    
    open func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {}
    
    
    fileprivate func updateSettings(_ userInfo: [String : AnyObject]) {
        // Update each incoming setting
        for (key, value) in userInfo {
            self.writeObjectToStore(value, key: key)
        }
        
        // Send a notification for the view controllers to refresh
        NotificationCenter.default.post(name: Notification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object:nil, userInfo:nil)
        print("Sent 'Update Settings' notification")
    }
}

