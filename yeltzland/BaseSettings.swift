//
//  BaseSettings.swift
//  yeltzland
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import WatchConnectivity

public class BaseSettings : NSObject {
    
    public static let SettingsUpdateNotification:String = "YLZSettingsUpdateNotification"

    var appStandardUserDefaults: UserDefaults?
    var watchSessionInitialised: Bool = false
    
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.yeltzland") {
        super.init()
        
        // Setup the default preferences
        let defaultPrefsFile: URL? = Bundle.main.url(forResource: defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOf:defaultPrefsFile!)
        
        self.appStandardUserDefaults = UserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults!.register(defaults: defaultPrefs as! [String: AnyObject]);
        
        // Migrate old settings if required
        self.migrateSettingsToGroup()
    }
    
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
    
    
    public var currentGameTime: Date {
        get { return self.readObjectFromStore("currentGameTime") as! Date }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameTime") }
    }
    
    public var currentGameYeltzScore: Int {
        get { return self.readObjectFromStore("currentGameYeltzScore") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameYeltzScore") }
    }
    
    public var currentGameOpponentScore: Int {
        get { return self.readObjectFromStore("currentGameOpponentScore") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameOpponentScore") }
    }

        
    func readObjectFromStore(_ key: String) -> AnyObject?{
        // Otherwise try the user details
        let userSettingsValue = self.appStandardUserDefaults!.value(forKey: key)
        
        return userSettingsValue as AnyObject?
    }
    
    func writeObjectToStore(_ value: AnyObject, key: String) {
        // Write to local user settings
        self.appStandardUserDefaults!.set(value, forKey:key)
        self.appStandardUserDefaults!.synchronize()
    }
    
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
    
    
    fileprivate func truncateTeamName(_ original:String, max:Int) -> String {
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
            firstSpace = firstSpace + 1
        }
        
        if (firstSpace < max) {
            return String(original[original.startIndex..<original.index(original.startIndex, offsetBy: firstSpace)])
        }
        
        // If still not found, just truncate it
        return original[original.startIndex..<original.index(original.startIndex, offsetBy: max)].trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }
    
    @objc public func updateLatestScoreSettings() {
        print("Updating game score settings ...")
        
        /* TODO: Implement this better
        let currentlyInGame = self.currentGameState() == GameState.during
        
        if let currentGame = GameScoreManager.instance.CurrentFixture {
            var updated = false
            
            let currentGameYeltzScore = currentGame.teamScore
            let currentGameOpponentScore = currentGame.opponentScore
            
            if (self.currentGameTime.compare(currentGameTime as Date) != ComparisonResult.orderedSame) {
                self.currentGameTime = currentGameTime as Date
                updated = true
            }
            
            if (self.currentGameYeltzScore != currentGameYeltzScore) {
                self.currentGameYeltzScore = currentGameYeltzScore
                updated = true
            }
            
            if (self.currentGameOpponentScore != currentGameOpponentScore) {
                self.currentGameOpponentScore = currentGameOpponentScore
                updated = true
            }
            
            // If any values have been changed, push then to the watch
            if (updated) {
                self.pushAllSettingsToWatch(currentlyInGame)
                NotificationCenter.default.post(name: Notification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
            } else {
                print("No game settings changed")
            }
        }
         */
    }
    
    public func getLatestFixtureFromSettings() -> Fixture? {
        // TODO: Get this from settings
        var latestFixture:Fixture? = FixtureManager.instance.getLastGame()
        
        if let currentFixture = GameScoreManager.instance.CurrentFixture {
            if currentFixture.inProgress {
                latestFixture = currentFixture
            }
        }
        
        return latestFixture
    }

    
    public func pushAllSettingsToWatch(_ currentlyInGame:Bool) {
        // Do nothing by default
    }
}
