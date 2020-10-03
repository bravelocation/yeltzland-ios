//
//  BaseSettings.swift
//  yeltzland
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import WatchConnectivity

public class BaseSettings: NSObject {
    
    public static let SettingsUpdateNotification: String = "YLZSettingsUpdateNotification"

    // MARK: - Properties
    var appStandardUserDefaults: UserDefaults?
    var watchSessionInitialised: Bool = false
    
    // MARK: - Initialisation
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.yeltzland") {
        super.init()
        
        // Setup the default preferences
        let defaultPrefsFile: URL? = Bundle.main.url(forResource: defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOf: defaultPrefsFile!)
        
        self.appStandardUserDefaults = UserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults!.register(defaults: defaultPrefs as! [String: AnyObject])
        
        // Migrate old settings if required
        self.migrateSettingsToGroup()
    }
    
    // MARK: - App settings
    public var gameTimeTweetsEnabled: Bool {
        get { return self.readObjectFromStore("GameTimeTweetsEnabled") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "GameTimeTweetsEnabled") }
    }
    
    public var lastSelectedTab: Int {
        get { return self.readObjectFromStore("LastSelectedTab") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "LastSelectedTab") }
    }
    
    public var migratedToGroupSettings: Bool {
        get { return self.readObjectFromStore("migratedToGroupSettings") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "migratedToGroupSettings") }
    }
    
    // MARK: - Current game settings
    var currentGameTime: Date {
        get { return self.readObjectFromStore("currentGameTime") as! Date }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameTime") }
    }
    
    var currentGameYeltzScore: Int {
        get { return self.readObjectFromStore("currentGameYeltzScore") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameYeltzScore") }
    }
    
    var currentGameOpponentScore: Int {
        get { return self.readObjectFromStore("currentGameOpponentScore") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameOpponentScore") }
    }
    
    var currentGameOpponentName: String {
        get { return self.readObjectFromStore("currentGameOpponentName") as! String }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameOpponentName") }
    }
    
    var currentGameHome: Bool {
        get { return self.readObjectFromStore("currentGameHome") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameHome") }
    }
    
    var currentGameInProgress: Bool {
        get { return self.readObjectFromStore("currentGameInProgress") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameInProgress") }
    }

    // MARK: - Latest score functions
    @objc public func updateLatestScoreSettings() {
        print("Updating game score settings ...")
        
        var updatedSettings = GameScoreManager.shared.currentFixture
        
        if updatedSettings == nil {
            updatedSettings = FixtureManager.shared.lastGame
        }
        
        if let currentSettings = self.getLatestFixtureFromSettings(), let newSettings = updatedSettings {
            self.currentGameTime = newSettings.fixtureDate
            self.currentGameOpponentName = newSettings.opponent
            self.currentGameYeltzScore = newSettings.teamScore ?? 0
            self.currentGameOpponentScore = newSettings.opponentScore ?? 0
            self.currentGameHome = newSettings.home
            self.currentGameInProgress = newSettings.inProgress
            
            self.pushAllSettingsToWatch(currentSettings.inProgress || newSettings.inProgress)
            NotificationCenter.default.post(name: Notification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
        }
    }
    
    public func getLatestFixtureFromSettings() -> Fixture? {
        return Fixture(date: self.currentGameTime,
                       opponent: self.currentGameOpponentName,
                       home: self.currentGameHome,
                       teamScore: self.currentGameYeltzScore,
                       opponentScore: self.currentGameOpponentScore)
    }
    
    public func pushAllSettingsToWatch(_ currentlyInGame: Bool) {
        // Do nothing by default
    }

    // MARK: - Read/write helpers
    private func readObjectFromStore(_ key: String) -> AnyObject? {
        // Otherwise try the user details
        let userSettingsValue = self.appStandardUserDefaults!.value(forKey: key)
        
        return userSettingsValue as AnyObject?
    }
    
    private func writeObjectToStore(_ value: AnyObject, key: String) {
        // Write to local user settings
        self.appStandardUserDefaults!.set(value, forKey: key)
        self.appStandardUserDefaults!.synchronize()
    }
    
    // MARK: - Helper functions
    fileprivate func migrateSettingsToGroup() {
        if (self.migratedToGroupSettings) {
            return
        }
        
        let defaults = UserDefaults.standard
        
        self.lastSelectedTab = defaults.integer(forKey: "LastSelectedTab")
        self.gameTimeTweetsEnabled = defaults.bool(forKey: "GameTimeTweetsEnabled")
        self.migratedToGroupSettings = true
        
        print("Migrated settings to group")
    }
    
    fileprivate func truncateTeamName(_ original: String, max: Int) -> String {
        let originalLength = original.count
        
        // If the original is short enough, we're done
        if (originalLength <= max) {
            return original
        }
        
        // Find the first space
        var firstSpace = 0
        for c in original {
            if (c == Character(" ")) {
                break
            }
            firstSpace += 1
        }
        
        if (firstSpace < max) {
            return String(original[original.startIndex..<original.index(original.startIndex, offsetBy: firstSpace)])
        }
        
        // If still not found, just truncate it
        return original[original.startIndex..<original.index(original.startIndex, offsetBy: max)].trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }
}
