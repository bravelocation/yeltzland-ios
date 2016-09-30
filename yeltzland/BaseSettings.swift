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

    var appStandardUserDefaults: NSUserDefaults?
    var watchSessionInitialised: Bool = false
    
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.yeltzland") {
        super.init()
        
        // Setup the default preferences
        let defaultPrefsFile: NSURL? = NSBundle.mainBundle().URLForResource(defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOfURL:defaultPrefsFile!)
        
        self.appStandardUserDefaults = NSUserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults!.registerDefaults(defaultPrefs as! [String: AnyObject]);
        
        // Migrate old settings if required
        self.migrateSettingsToGroup()
    }
    
    public var gameTimeTweetsEnabled: Bool {
        get { return self.readObjectFromStore("GameTimeTweetsEnabled") as! Bool }
        set { self.writeObjectToStore(newValue, key: "GameTimeTweetsEnabled") }
    }
    
    public var lastSelectedTab: Int {
        get { return self.readObjectFromStore("LastSelectedTab") as! Int }
        set { self.writeObjectToStore(newValue, key: "LastSelectedTab") }
    }
    
    public var lastGameTime: NSDate {
        get { return self.readObjectFromStore("lastGameTime") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "lastGameTime") }
    }
    
    public var lastGameTeam: String {
        get { return self.readObjectFromStore("lastGameTeam") as! String }
        set { self.writeObjectToStore(newValue, key: "lastGameTeam") }
    }
    
    public var lastGameYeltzScore: Int {
        get { return self.readObjectFromStore("lastGameYeltzScore") as! Int }
        set { self.writeObjectToStore(newValue, key: "lastGameYeltzScore") }
    }
    
    public var lastGameOpponentScore: Int {
        get { return self.readObjectFromStore("lastGameOpponentScore") as! Int }
        set { self.writeObjectToStore(newValue, key: "lastGameOpponentScore") }
    }
    
    public var lastGameHome: Bool {
        get { return self.readObjectFromStore("lastGameHome") as! Bool }
        set { self.writeObjectToStore(newValue, key: "lastGameHome") }
    }
    
    public var nextGameTime: NSDate {
        get { return self.readObjectFromStore("nextGameTime") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "nextGameTime") }
    }
    
    public var nextGameTeam: String {
        get { return self.readObjectFromStore("nextGameTeam") as! String }
        set { self.writeObjectToStore(newValue, key: "nextGameTeam") }
    }
    
    public var nextGameHome: Bool {
        get { return self.readObjectFromStore("nextGameHome") as! Bool }
        set { self.writeObjectToStore(newValue, key: "nextGameHome") }
    }
    
    public var currentGameTime: NSDate {
        get { return self.readObjectFromStore("currentGameTime") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "currentGameTime") }
    }
    
    public var currentGameYeltzScore: Int {
        get { return self.readObjectFromStore("currentGameYeltzScore") as! Int }
        set { self.writeObjectToStore(newValue, key: "currentGameYeltzScore") }
    }
    
    public var currentGameOpponentScore: Int {
        get { return self.readObjectFromStore("currentGameOpponentScore") as! Int }
        set { self.writeObjectToStore(newValue, key: "currentGameOpponentScore") }
    }
    
    public var migratedToGroupSettings: Bool {
        get { return self.readObjectFromStore("migratedToGroupSettings") as! Bool }
        set { self.writeObjectToStore(newValue, key: "migratedToGroupSettings") }
    }
    
    public var displayLastOpponent: String {
        get {
            return self.lastGameHome ? self.lastGameTeam.uppercaseString : self.lastGameTeam
        }
    }
    
    public var displayNextOpponent: String {
        get {
            return self.nextGameHome ? self.nextGameTeam.uppercaseString : self.nextGameTeam
        }
    }
    
    public var lastScore: String {
        get {
            // If no opponent, then no score
            if (self.lastGameTeam.characters.count == 0) {
                return ""
            }
            
            var result = ""
            if (self.lastGameYeltzScore > self.lastGameOpponentScore) {
                result = "W"
            } else if (self.lastGameYeltzScore < self.lastGameOpponentScore) {
                result = "L"
            } else {
                result = "D"
            }
            
            return String.init(format: "%@ %d-%d", result, self.lastGameYeltzScore, self.lastGameOpponentScore)
        }
    }
    
    public var currentScore: String {
        get {
            // If no opponent, then no current score
            if (self.nextGameTeam.characters.count == 0) {
                return ""
            }
            
            if self.currentGameState() == GameState.DuringNoScore {
                return "0-0*"
            }
            
            return String.init(format: "%d-%d*", self.currentGameYeltzScore, self.currentGameOpponentScore)
        }
    }
    
    public var nextKickoffTime: String {
        get {
            // If no opponent, then no kickoff time
            if (self.nextGameTeam.characters.count == 0) {
                return ""
            }
            
            let formatter = NSDateFormatter()
            let gameState = self.currentGameState()
            if (gameState == GameState.GameDayBefore || gameState == GameState.During)  {
                formatter.dateFormat = "HHmm"
            } else {
                formatter.dateFormat = "EEE dd MMM"
            }
        
            return formatter.stringFromDate(self.nextGameTime)
        }
    }
    
    public var gameScoreForCurrentGame: Bool {
        get {
            // If no opponent, then no current game
            if (self.nextGameTeam.characters.count == 0) {
                return false
            }
            
            return self.nextGameTime.compare(self.currentGameTime) == NSComparisonResult.OrderedSame
        }
    }
        
    func readObjectFromStore(key: String) -> AnyObject?{
        // Otherwise try the user details
        let userSettingsValue = self.appStandardUserDefaults!.valueForKey(key)
        
        return userSettingsValue
    }
    
    func writeObjectToStore(value: AnyObject, key: String) {
        // Write to local user settings
        self.appStandardUserDefaults!.setObject(value, forKey:key)
        self.appStandardUserDefaults!.synchronize()
    }
    
    private func migrateSettingsToGroup() {
        if (self.migratedToGroupSettings) {
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.lastSelectedTab = defaults.integerForKey("LastSelectedTab")
        self.gameTimeTweetsEnabled = defaults.boolForKey("GameTimeTweetsEnabled")
        self.migratedToGroupSettings = true
        
        print("Migrated settings to group")
    }
    
    public var truncateLastOpponent: String {
        get {
            return self.truncateTeamName(self.displayLastOpponent, max:16)
        }
    }
    
    public var truncateNextOpponent: String {
        get {
            return self.truncateTeamName(self.displayNextOpponent, max:16)
        }
    }
    
    public var smallOpponent: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return self.truncateTeamName(self.displayNextOpponent, max: 4)
            case .During, .DuringNoScore:
                return self.truncateTeamName(self.displayNextOpponent, max: 4)
            case .After:
                return self.truncateTeamName(self.displayLastOpponent, max: 4)
            case .None:
                return "None"
            }
        }
    }
    
    public var smallScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let now = NSDate()
                let todayDayNumber = self.dayNumber(now)
                let nextGameNumber = self.dayNumber(self.nextGameTime)
                
                let formatter = NSDateFormatter()
                
                if (nextGameNumber - todayDayNumber > 7) {
                    // If next game more than a week off, show the day number
                    formatter.dateFormat = "d"
                } else {
                    // Otherwise show the day name
                    formatter.dateFormat = "E"
                }
                
                return formatter.stringFromDate(self.nextGameTime)
            case .GameDayBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "HHmm"
                
                return formatter.stringFromDate(self.nextGameTime)
            case .During, .DuringNoScore:
                return self.currentScore
            case .After:
                return self.lastScore
            case .None:
                return ""
            }
        }
    }
    
    public var smallScore: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return self.lastScore
            case .During, .DuringNoScore:
                return self.currentScore
            case .After:
                return self.lastScore
            case .None:
                return ""
            }
        }
    }
    
    public var longCombinedTeamScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return String(format: "%@ %@", self.truncateLastOpponent, self.lastScore)
            case .During, .DuringNoScore:
                return String(format: "%@ %@", self.truncateNextOpponent, self.currentScore)
            case .After:
                return String(format: "%@ %@", self.truncateLastOpponent, self.lastScore)
            case .None:
                return ""
            }
        }
    }
    
    public var fullTitle: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return "Next game:"
            case .During, .DuringNoScore:
                return "Current score"
            case .After:
                return "Last game:"
            case .None:
                return ""
            }
        }
    }
    
    public var fullTeam: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return self.truncateNextOpponent
            case .During, .DuringNoScore:
                return self.truncateNextOpponent
            case .After:
                return self.truncateLastOpponent
            case .None:
                return ""
            }
        }
    }
    
    public var fullScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore:
                return self.nextKickoffTime
            case .GameDayBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "HHmm"
                let formattedTime = formatter.stringFromDate(self.nextGameTime)
                return String(format: "Today at %@", formattedTime)
            case .During, .DuringNoScore:
                return self.currentScore
            case .After:
                return self.lastScore
            case .None:
                return ""
            }
        }
    }
    
    private func truncateTeamName(original:String, max:Int) -> String {
        let originalLength = original.characters.count
        
        // If the original is short enough, we're done
        if (originalLength <= max) {
            return original
        }
        
        // Find the first space
        var firstSpace = 0
        for c in original.characters {
            if (c == Character(" ")) {
                break
            }
            firstSpace = firstSpace + 1
        }
        
        if (firstSpace < max) {
            return original[original.startIndex..<original.startIndex.advancedBy(firstSpace)]
        }
        
        // If still not found, just truncate it
        return original[original.startIndex..<original.startIndex.advancedBy(max)].stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
    }

    
    // MARK:- Game state functions
    public func currentGameState() -> GameState {
        
        // If no next game, return none
        if (self.nextGameTeam.characters.count == 0) {
            return GameState.None
        }
        
        // If we have a game score for the next match
        if (self.gameScoreForCurrentGame) {
            return GameState.During
        }
        
        let now = NSDate()
        let beforeKickoff = now.compare(self.nextGameTime) == NSComparisonResult.OrderedAscending
        let todayDayNumber = self.dayNumber(now)
        let lastGameNumber = self.dayNumber(self.lastGameTime)
        let nextGameNumber = self.dayNumber(self.nextGameTime)
        
        // If next game is today, and we are before kickoff ...
        if (nextGameNumber == todayDayNumber && beforeKickoff) {
            return GameState.GameDayBefore
        }
        
        // If last game was today or yesterday
        if ((lastGameNumber == todayDayNumber) || (lastGameNumber == todayDayNumber - 1)) {
            return GameState.After
        }
        
        // If next game is today and after kickoff also during
        if (nextGameNumber == todayDayNumber && beforeKickoff == false) {
            return GameState.DuringNoScore
        }
        
        // Must before next game
        return GameState.DaysBefore
    }
    
    public enum GameState {
        case DaysBefore
        case GameDayBefore
        case During
        case DuringNoScore
        case After
        case None
    }
    
    
    func dayNumber(date:NSDate) -> Int {
        // Removes the time components from a date
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let startOfDayComponents = calendar.components(unitFlags, fromDate: date)
        let startOfDay = calendar.dateFromComponents(startOfDayComponents)
        let intervalToStaryOfDay = startOfDay!.timeIntervalSince1970
        let daysDifference = floor(intervalToStaryOfDay) / 86400  // Number of seconds per day = 60 * 60 * 24 = 86400
        return Int(daysDifference)
    }
    
    public func refreshFixtures() {
        print("Updating game fixture settings ...")
        
        var updated = false
        var lastGameTeam = ""
        var lastGameYeltzScore = 0
        var lastGameOpponentScore = 0
        var lastGameHome = false
        var lastGameTime:NSDate? = nil
        
        let gameState = self.currentGameState()
        let currentlyInGame = (gameState == GameState.During || gameState == GameState.DuringNoScore)
        
        if let lastGame = FixtureManager.instance.getLastGame() {
            lastGameTime = lastGame.fixtureDate
            lastGameTeam = lastGame.opponent
            lastGameYeltzScore = lastGame.teamScore!
            lastGameOpponentScore = lastGame.opponentScore!
            lastGameHome = lastGame.home
        }
        
        if (lastGameTime != nil && self.lastGameTime.compare(lastGameTime!) != NSComparisonResult.OrderedSame) {
            self.lastGameTime = lastGameTime!
            updated = true
        }
        
        if (self.lastGameTeam != lastGameTeam) {
            self.lastGameTeam = lastGameTeam
            updated = true
        }
        
        if (self.lastGameYeltzScore != lastGameYeltzScore) {
            self.lastGameYeltzScore = lastGameYeltzScore
            updated = true
        }
        
        if (self.lastGameOpponentScore != lastGameOpponentScore) {
            self.lastGameOpponentScore = lastGameOpponentScore
            updated = true
        }
        
        if (self.lastGameHome != lastGameHome) {
            self.lastGameHome = lastGameHome
            updated = true
        }
        
        
        var nextGameTeam = ""
        var nextGameHome = false
        var nextGameTime:NSDate? = nil
        
        if let nextGame = FixtureManager.instance.getNextGame() {
            nextGameTime = nextGame.fixtureDate
            nextGameTeam = nextGame.opponent
            nextGameHome = nextGame.home
        }
        
        if (nextGameTime != nil && self.nextGameTime.compare(nextGameTime!) != NSComparisonResult.OrderedSame) {
            self.nextGameTime = nextGameTime!
            updated = true
        }
        
        if (self.nextGameTeam != nextGameTeam) {
            self.nextGameTeam = nextGameTeam
            updated = true
        }
        
        if (self.nextGameHome != nextGameHome) {
            self.nextGameHome = nextGameHome
            updated = true
        }
        
        // If any values have been changed, push then to the watch
        if (updated) {
            self.pushAllSettingsToWatch(currentlyInGame)
            
            NSNotificationCenter.defaultCenter().postNotificationName(BaseSettings.SettingsUpdateNotification, object: nil)
        } else {
            print("No fixture settings changed")
        }
    }
    
    public func refreshGameScore() {
        print("Updating game score settings ...")
        
        let currentlyInGame = self.currentGameState() == GameState.During
        
        if let currentGameTime = GameScoreManager.instance.MatchDate {
            var updated = false
            
            let currentGameYeltzScore = GameScoreManager.instance.YeltzScore
            let currentGameOpponentScore = GameScoreManager.instance.OpponentScore
            
            if (self.currentGameTime.compare(currentGameTime) != NSComparisonResult.OrderedSame) {
                self.currentGameTime = currentGameTime
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
                NSNotificationCenter.defaultCenter().postNotificationName(BaseSettings.SettingsUpdateNotification, object: nil)
            } else {
                print("No game settings changed")
            }
        }
    }
    
    public func pushAllSettingsToWatch(currentlyInGame:Bool) {
        // Do nothing by default
    }
}
