//
//  Fixture.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class Fixture {
    var fixtureDate: Date
    var opponent: String
    var home: Bool
    var teamScore: Int?
    var opponentScore: Int?
    
    init?(fromJson: [String:AnyObject]) {
        // Parse properties from JSON match properties
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"        
        guard let matchDateTime = fromJson["MatchDateTime"] as! String? else { return nil }
        let parsedDate = formatter.date(from: matchDateTime)
        if (parsedDate == nil) {
            return nil
        }
        self.fixtureDate = parsedDate!
        
        guard let opponent = fromJson["Opponent"] as! String? else { return nil }
        self.opponent = opponent
        
        guard let home = fromJson["Home"] as! String? else { return nil }
        self.home = (home == "1")
        
        // Parse scores or "null"
        if let parsedTeamScore = fromJson["TeamScore"] as? String {
            self.teamScore = Int(parsedTeamScore)
        }
        
        if let parsedOpponentScore = fromJson["OpponentScore"] as? String {
            self.opponentScore = Int(parsedOpponentScore)
        }
    }
    
    init(date: Date, opponent:String, home:Bool, teamScore: Int?, opponentScore: Int?) {
        self.fixtureDate = date
        self.opponent = opponent
        self.home = home
        self.teamScore = teamScore
        self.opponentScore = opponentScore
    }
    
    var kickoffTime: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE dd"
            
            return formatter.string(from: self.fixtureDate)
        }
    }
    
    var fullKickoffTime: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE dd MMM"
            
            return formatter.string(from: self.fixtureDate)
        }
    }
    
    var displayKickoffTime : String {
        get {
            // Is the game today?
            let now = Date()
            let currentDayNumber = FixtureManager.instance.dayNumber(now)
            let fixtureDayNumber = FixtureManager.instance.dayNumber(self.fixtureDate)
            
            if (currentDayNumber == fixtureDayNumber) {
                let formatter = DateFormatter()
                formatter.dateFormat = "HHmm"
                
                return formatter.string(from: self.fixtureDate)
            } else {
                return self.kickoffTime
            }
        }
    }
    
    var fixtureMonth: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            
            return formatter.string(from: self.fixtureDate)
        }
    }
    
    var monthKey: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMM"
            
            return formatter.string(from: self.fixtureDate)
        }
    }
    
    var displayOpponent: String {
        get {
            return self.home ? self.opponent.uppercased() : self.opponent
        }
    }
    
    var score: String {
        get {
            if ((self.teamScore == nil) || (self.opponentScore == nil)) {
                return ""
            }
            
            var result = ""
            if (self.teamScore > self.opponentScore) {
                result = "W"
            } else if (self.teamScore < self.opponentScore) {
                result = "L"
            } else {
                result = "D"
            }
            
            return String.init(format: "%@ %d-%d", result, self.teamScore!, self.opponentScore!)
        }
    }
}
