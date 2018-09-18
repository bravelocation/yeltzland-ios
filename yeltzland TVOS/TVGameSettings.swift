//
//  TVGameSettings.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import Foundation

public class TVGameSettings {
    
    public var gameScoreForCurrentGame: Bool {
        get {
            if let nextGameTime = self.nextGameTime {
                if let currentGameTime = self.currentGameTime {
                    return nextGameTime.compare(currentGameTime) == ComparisonResult.orderedSame
                }
            }
            
            // If no next game, then no current game
            return false
        }
    }
    
    public var nextGameTime: Date? {
        get {
            if let nextGame = FixtureManager.instance.getNextGame() {
                return nextGame.fixtureDate
            }
            
            return nil
        }
    }
    
    public var currentGameTime: Date? {
        get {
            return GameScoreManager.instance.MatchDate
        }
    }
    
    public var currentGameYeltzScore: Int {
        get {
            return GameScoreManager.instance.YeltzScore
        }
    }
    
    public var currentGameOpponentScore: Int {
        get {
            return GameScoreManager.instance.OpponentScore
        }
    }
    
    public var nextGameTeam: String? {
        get {
            if let nextGame = FixtureManager.instance.getNextGame() {
                return nextGame.opponent
            }
            
            return nil
        }
    }
    
    public var lastGameTime: Date? {
        get {
            if let lastGame = FixtureManager.instance.getLastGame() {
                return lastGame.fixtureDate
            }
            
            return nil
        }
    }
    
    public var currentScore: String {
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
    public func currentGameState() -> GameState {
        
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
