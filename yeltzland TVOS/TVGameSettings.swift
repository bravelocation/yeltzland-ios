//
//  TVGameSettings.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import Foundation

open class TVGameSettings {
    open var displayLastOpponent: String {
        get {
            if (self.lastGameHome != nil && self.lastGameTeam != nil) {
                return self.lastGameHome! ? self.lastGameTeam!.uppercased() : self.lastGameTeam!
            }
            
            return ""
        }
    }
    
    open var lastGameHome: Bool? {
        get {
            if let lastGame = FixtureManager.instance.getLastGame() {
                return lastGame.home
            }
            
            return nil
        }
    }
    
    open var lastGameTeam: String? {
        get {
            if let lastGame = FixtureManager.instance.getLastGame() {
                return lastGame.opponent
            }
            
            return nil
        }
    }
    
    open var lastGameYeltzScore: Int? {
        get {
            if let lastGame = FixtureManager.instance.getLastGame() {
                return lastGame.teamScore
            }
            
            return nil
        }
    }
    
    open var lastGameOpponentScore: Int? {
        get {
            if let lastGame = FixtureManager.instance.getLastGame() {
                return lastGame.opponentScore
            }
            
            return nil
        }
    }
    
    
    open var lastScore: String {
        get {
            // If no opponent, then no score
            if (self.lastGameTeam == nil) {
                return ""
            }
            
            var result = ""
            if (self.lastGameYeltzScore! > self.lastGameOpponentScore!) {
                result = "W"
            } else if (self.lastGameYeltzScore! < self.lastGameOpponentScore!) {
                result = "L"
            } else {
                result = "D"
            }
            
            return String.init(format: "%@ %d-%d", result, self.lastGameYeltzScore!, self.lastGameOpponentScore!)
        }
    }
    
    open var lastGameTime: Date? {
        get {
            if let lastGame = FixtureManager.instance.getLastGame() {
                return lastGame.fixtureDate
            }
            
            return nil
        }
    }

    open var gameScoreForCurrentGame: Bool {
        get {
            // If no next game, then no current game
            if (self.nextGameTime == nil) {
                return false
            }
            
            return self.nextGameTime!.compare(self.currentGameTime) == ComparisonResult.orderedSame
        }
    }
    
    open var nextGameTime: Date? {
        get {
            if let nextGame = FixtureManager.instance.getNextGame() {
                return nextGame.fixtureDate
            }
            
            return nil
        }
    }
    
    open var displayNextOpponent: String {
        get {
            if (self.nextGameHome != nil && self.nextGameTeam != nil) {
                return self.nextGameHome! ? self.nextGameTeam!.uppercased() : self.nextGameTeam!
            }
            
            return ""
        }
    }
    
    open var nextGameHome: Bool? {
        get {
            if let nextGame = FixtureManager.instance.getNextGame() {
                return nextGame.home
            }
            
            return nil
        }
    }
    
    open var nextGameTeam: String? {
        get {
            if let nextGame = FixtureManager.instance.getNextGame() {
                return nextGame.opponent
            }
            
            return nil
        }
    }
    
    open var currentGameTime: Date {
        get {
            // TODO:
            return Date()
        }
    }
    
    open var currentGameYeltzScore: Int {
        // TODO
        get { return 0 }
    }
    
    open var currentGameOpponentScore: Int {
        // TODO
        get { return 0 }
    }
    
    open var currentScore: String {
        get {
            // If no opponent, then no current score
            if (self.nextGameTeam == nil) {
                return ""
            }
            
            if self.currentGameState() == GameState.duringNoScore {
                return "0-0*"
            }
            
            return String.init(format: "%d-%d*", self.currentGameYeltzScore, self.currentGameOpponentScore)
        }
    }
    
    // MARK:- Game state functions
    open func currentGameState() -> GameState {
        
        // If no next game, return none
        if (self.nextGameTime == nil) {
            return GameState.none
        }
        
        // If we have a game score for the next match
        if (self.gameScoreForCurrentGame) {
            return GameState.during
        }
        
        let now = Date()
        let beforeKickoff = now.compare(self.nextGameTime!) == ComparisonResult.orderedAscending
        let todayDayNumber = self.dayNumber(now)
        let nextGameNumber = self.dayNumber(self.nextGameTime!)
        
        // If next game is today, and we are before kickoff ...
        if (nextGameNumber == todayDayNumber && beforeKickoff) {
            return GameState.gameDayBefore
        }
        
        // If no last game time (but is a next, must be before)
        if (self.lastGameTime == nil) {
            return GameState.daysBefore
        }
        
        let lastGameNumber = self.dayNumber(self.lastGameTime!)
        
        
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
}
