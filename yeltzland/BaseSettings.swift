//
//  BaseSettings.swift
//  yeltzland
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import WatchConnectivity

open class BaseSettings : NSObject {
    
    open static let SettingsUpdateNotification:String = "YLZSettingsUpdateNotification"

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
    
    open var gameTimeTweetsEnabled: Bool {
        get { return self.readObjectFromStore("GameTimeTweetsEnabled") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "GameTimeTweetsEnabled") }
    }
    
    open var lastSelectedTab: Int {
        get { return self.readObjectFromStore("LastSelectedTab") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "LastSelectedTab") }
    }
    
    open var lastGameTime: Date {
        get { return self.readObjectFromStore("lastGameTime") as! Date }
        set { self.writeObjectToStore(newValue as AnyObject, key: "lastGameTime") }
    }
    
    open var lastGameTeam: String {
        get { return self.readObjectFromStore("lastGameTeam") as! String }
        set { self.writeObjectToStore(newValue as AnyObject, key: "lastGameTeam") }
    }
    
    open var lastGameYeltzScore: Int {
        get { return self.readObjectFromStore("lastGameYeltzScore") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "lastGameYeltzScore") }
    }
    
    open var lastGameOpponentScore: Int {
        get { return self.readObjectFromStore("lastGameOpponentScore") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "lastGameOpponentScore") }
    }
    
    open var lastGameHome: Bool {
        get { return self.readObjectFromStore("lastGameHome") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "lastGameHome") }
    }
    
    open var nextGameTime: Date {
        get { return self.readObjectFromStore("nextGameTime") as! Date }
        set { self.writeObjectToStore(newValue as AnyObject, key: "nextGameTime") }
    }
    
    open var nextGameTeam: String {
        get { return self.readObjectFromStore("nextGameTeam") as! String }
        set { self.writeObjectToStore(newValue as AnyObject, key: "nextGameTeam") }
    }
    
    open var nextGameHome: Bool {
        get { return self.readObjectFromStore("nextGameHome") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "nextGameHome") }
    }
    
    open var currentGameTime: Date {
        get { return self.readObjectFromStore("currentGameTime") as! Date }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameTime") }
    }
    
    open var currentGameYeltzScore: Int {
        get { return self.readObjectFromStore("currentGameYeltzScore") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameYeltzScore") }
    }
    
    open var currentGameOpponentScore: Int {
        get { return self.readObjectFromStore("currentGameOpponentScore") as! Int }
        set { self.writeObjectToStore(newValue as AnyObject, key: "currentGameOpponentScore") }
    }
    
    open var migratedToGroupSettings: Bool {
        get { return self.readObjectFromStore("migratedToGroupSettings") as! Bool }
        set { self.writeObjectToStore(newValue as AnyObject, key: "migratedToGroupSettings") }
    }
    
    open var displayLastOpponent: String {
        get {
            return self.lastGameHome ? self.lastGameTeam.uppercased() : self.lastGameTeam
        }
    }
    
    open var displayNextOpponent: String {
        get {
            return self.nextGameHome ? self.nextGameTeam.uppercased() : self.nextGameTeam
        }
    }
    
    open var lastScore: String {
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
    
    open var currentScore: String {
        get {
            // If no opponent, then no current score
            if (self.nextGameTeam.characters.count == 0) {
                return ""
            }
            
            if self.currentGameState() == GameState.duringNoScore {
                return "0-0*"
            }
            
            return String.init(format: "%d-%d*", self.currentGameYeltzScore, self.currentGameOpponentScore)
        }
    }
    
    open var nextKickoffTime: String {
        get {
            // If no opponent, then no kickoff time
            if (self.nextGameTeam.characters.count == 0) {
                return ""
            }
            
            let formatter = DateFormatter()
            let gameState = self.currentGameState()
            if (gameState == GameState.gameDayBefore || gameState == GameState.during)  {
                formatter.dateFormat = "HHmm"
            } else {
                formatter.dateFormat = "EEE dd MMM"
            }
        
            return formatter.string(from: self.nextGameTime)
        }
    }
    
    open var gameScoreForCurrentGame: Bool {
        get {
            // If no opponent, then no current game
            if (self.nextGameTeam.characters.count == 0) {
                return false
            }
            
            return self.nextGameTime.compare(self.currentGameTime) == ComparisonResult.orderedSame
        }
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
    
    open var truncateLastOpponent: String {
        get {
            return self.truncateTeamName(self.displayLastOpponent, max:16)
        }
    }
    
    open var truncateNextOpponent: String {
        get {
            return self.truncateTeamName(self.displayNextOpponent, max:16)
        }
    }
    
    open var smallOpponent: String {
        get {
            switch self.currentGameState() {
            case .daysBefore, .gameDayBefore:
                return self.truncateTeamName(self.displayNextOpponent, max: 4)
            case .during, .duringNoScore:
                return self.truncateTeamName(self.displayNextOpponent, max: 4)
            case .after:
                return self.truncateTeamName(self.displayLastOpponent, max: 4)
            case .none:
                return "None"
            }
        }
    }
    
    open var smallScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .daysBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let now = Date()
                let todayDayNumber = self.dayNumber(now)
                let nextGameNumber = self.dayNumber(self.nextGameTime)
                
                let formatter = DateFormatter()
                
                if (nextGameNumber - todayDayNumber > 7) {
                    // If next game more than a week off, show the day number
                    formatter.dateFormat = "d"
                } else {
                    // Otherwise show the day name
                    formatter.dateFormat = "E"
                }
                
                return formatter.string(from: self.nextGameTime)
            case .gameDayBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HHmm"
                
                return formatter.string(from: self.nextGameTime)
            case .during, .duringNoScore:
                return self.currentScore
            case .after:
                return self.lastScore
            case .none:
                return ""
            }
        }
    }
    
    open var smallScore: String {
        get {
            switch self.currentGameState() {
            case .daysBefore, .gameDayBefore:
                return self.lastScore
            case .during, .duringNoScore:
                return self.currentScore
            case .after:
                return self.lastScore
            case .none:
                return ""
            }
        }
    }
    
    open var longCombinedTeamScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .daysBefore, .gameDayBefore:
                return String(format: "%@ %@", self.truncateLastOpponent, self.lastScore)
            case .during, .duringNoScore:
                return String(format: "%@ %@", self.truncateNextOpponent, self.currentScore)
            case .after:
                return String(format: "%@ %@", self.truncateLastOpponent, self.lastScore)
            case .none:
                return ""
            }
        }
    }
    
    open var fullTitle: String {
        get {
            switch self.currentGameState() {
            case .daysBefore, .gameDayBefore:
                return "Next game:"
            case .during, .duringNoScore:
                return "Current score"
            case .after:
                return "Last game:"
            case .none:
                return ""
            }
        }
    }
    
    open var fullTeam: String {
        get {
            switch self.currentGameState() {
            case .daysBefore, .gameDayBefore:
                return self.truncateNextOpponent
            case .during, .duringNoScore:
                return self.truncateNextOpponent
            case .after:
                return self.truncateLastOpponent
            case .none:
                return ""
            }
        }
    }
    
    open var fullScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .daysBefore:
                return self.nextKickoffTime
            case .gameDayBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HHmm"
                let formattedTime = formatter.string(from: self.nextGameTime)
                return String(format: "Today at %@", formattedTime)
            case .during, .duringNoScore:
                return self.currentScore
            case .after:
                return self.lastScore
            case .none:
                return ""
            }
        }
    }
    
    fileprivate func truncateTeamName(_ original:String, max:Int) -> String {
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
            return original[original.startIndex..<original.characters.index(original.startIndex, offsetBy: firstSpace)]
        }
        
        // If still not found, just truncate it
        return original[original.startIndex..<original.characters.index(original.startIndex, offsetBy: max)].trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }

    
    // MARK:- Game state functions
    open func currentGameState() -> GameState {
        
        // If no next game, return none
        if (self.nextGameTeam.characters.count == 0) {
            return GameState.none
        }
        
        // If we have a game score for the next match
        if (self.gameScoreForCurrentGame) {
            return GameState.during
        }
        
        let now = Date()
        let beforeKickoff = now.compare(self.nextGameTime) == ComparisonResult.orderedAscending
        let todayDayNumber = self.dayNumber(now)
        let lastGameNumber = self.dayNumber(self.lastGameTime)
        let nextGameNumber = self.dayNumber(self.nextGameTime)
        
        // If next game is today, and we are before kickoff ...
        if (nextGameNumber == todayDayNumber && beforeKickoff) {
            return GameState.gameDayBefore
        }
        
        // If last game was today or yesterday
        if ((lastGameNumber == todayDayNumber) || (lastGameNumber == todayDayNumber - 1)) {
            return GameState.after
        }
        
        // If next game is today and after kickoff also during
        if (nextGameNumber == todayDayNumber && beforeKickoff == false) {
            return GameState.duringNoScore
        }
        
        // Must before next game
        return GameState.daysBefore
    }
    
    public enum GameState {
        case daysBefore
        case gameDayBefore
        case during
        case duringNoScore
        case after
        case none
    }
    
    
    func dayNumber(_ date:Date) -> Int {
        // Removes the time components from a date
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.day, .month, .year]
        let startOfDayComponents = (calendar as NSCalendar).components(unitFlags, from: date)
        let startOfDay = calendar.date(from: startOfDayComponents)
        let intervalToStaryOfDay = startOfDay!.timeIntervalSince1970
        let daysDifference = floor(intervalToStaryOfDay) / 86400  // Number of seconds per day = 60 * 60 * 24 = 86400
        return Int(daysDifference)
    }
    
    open func refreshFixtures() {
        print("Updating game fixture settings ...")
        
        var updated = false
        var lastGameTeam = ""
        var lastGameYeltzScore = 0
        var lastGameOpponentScore = 0
        var lastGameHome = false
        var lastGameTime:Date? = nil
        
        let gameState = self.currentGameState()
        let currentlyInGame = (gameState == GameState.during || gameState == GameState.duringNoScore)
        
        if let lastGame = FixtureManager.instance.getLastGame() {
            lastGameTime = lastGame.fixtureDate as Date
            lastGameTeam = lastGame.opponent
            lastGameYeltzScore = lastGame.teamScore!
            lastGameOpponentScore = lastGame.opponentScore!
            lastGameHome = lastGame.home
        }
        
        if (lastGameTime != nil && self.lastGameTime.compare(lastGameTime!) != ComparisonResult.orderedSame) {
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
        var nextGameTime:Date? = nil
        
        if let nextGame = FixtureManager.instance.getNextGame() {
            nextGameTime = nextGame.fixtureDate as Date
            nextGameTeam = nextGame.opponent
            nextGameHome = nextGame.home
        }
        
        if (nextGameTime != nil && self.nextGameTime.compare(nextGameTime!) != ComparisonResult.orderedSame) {
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
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
        } else {
            print("No fixture settings changed")
        }
    }
    
    open func refreshGameScore() {
        print("Updating game score settings ...")
        
        let currentlyInGame = self.currentGameState() == GameState.during
        
        if let currentGameTime = GameScoreManager.instance.MatchDate {
            var updated = false
            
            let currentGameYeltzScore = GameScoreManager.instance.YeltzScore
            let currentGameOpponentScore = GameScoreManager.instance.OpponentScore
            
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
    }
    
    open func pushAllSettingsToWatch(_ currentlyInGame:Bool) {
        // Do nothing by default
    }
}
