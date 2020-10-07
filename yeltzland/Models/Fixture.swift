//
//  Fixture.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

public struct Fixture: Hashable {
    var fixtureDate: Date
    var opponent: String
    var home: Bool
    var teamScore: Int?
    var opponentScore: Int?
    var inProgress = false
    
    init?(fromJson: [String: AnyObject]) {
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
    
    init(date: Date, opponent: String, home: Bool, teamScore: Int?, opponentScore: Int?, inProgress: Bool) {
        self.fixtureDate = date
        self.opponent = opponent
        self.home = home
        self.teamScore = teamScore
        self.opponentScore = opponentScore
        self.inProgress = inProgress
    }
    
    var afterKickoff: Bool {
        get {
            return Date() > self.fixtureDate
        }
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
    
    var displayKickoffTime: String {
        get {
            // Is the game today?
            if (self.isToday) {
                let formatter = DateFormatter()
                formatter.dateFormat = "HHmm"
                
                return formatter.string(from: self.fixtureDate)
            } else {
                return self.kickoffTime
            }
        }
    }

    var fullDisplayKickoffTime: String {
        get {
            // Is the game today?
            if (self.isToday) {
                let formatter = DateFormatter()
                formatter.dateFormat = "HHmm"
                
                return formatter.string(from: self.fixtureDate)
            } else {
                return self.fullKickoffTime
            }
        }
    }
    
    var tvFixtureDisplayKickoffTime: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "HHmm"
            
            return String.init(format: "%@ at %@", self.fullKickoffTime, formatter.string(from: self.fixtureDate))
        }
    }
    
    var voiceKickoffTime: String {
        get {
            let formatter = DateFormatter()
            var prefix = ""
            
            // Is the game today?
            if (self.isToday) {
                prefix = "at"
                formatter.dateFormat = "h:mm a"
            } else {
                prefix = "on"
                formatter.dateFormat = "EEE dd MMM"
            }
            
            return "\(prefix) \(formatter.string(from: self.fixtureDate))"
        }
    }
    
    var tvResultDisplayKickoffTime: String {
        get {
            // Is the game today?
            if (self.isToday) {
                let formatter = DateFormatter()
                formatter.dateFormat = "HHmm"
                
                return String.init(format: "Today at %@", formatter.string(from: self.fixtureDate))
            } else {
                return self.fullKickoffTime
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
    
    public var opponentNoCup: String {
        // Do we have a bracket in the name
        let bracketPos = self.opponent.firstIndex(of: "(")
        if bracketPos == nil {
            return self.opponent
        } else {
            let beforeBracket = self.opponent.split(separator: "(", maxSplits: 1, omittingEmptySubsequences: true)[0]
            return beforeBracket.trimmingCharacters(in: CharacterSet(charactersIn: " "))
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

    var inProgressScore: String {
        get {
            if ((self.teamScore == nil) || (self.opponentScore == nil)) {
                return ""
            }
            
            return String.init(format: "%d-%d%@", self.teamScore!, self.opponentScore!, self.inProgress ? "*" : "")
        }
    }
    
    var isToday: Bool {
        // Is the game today?
        let now = Date()
        let currentDayNumber = DateHelper.dayNumber(now)
        let fixtureDayNumber = DateHelper.dayNumber(self.fixtureDate)
        
        return currentDayNumber == fixtureDayNumber
    }
}

extension Fixture: Equatable {
  static public func == (lhs: Fixture, rhs: Fixture) -> Bool {
    return lhs.opponent == rhs.opponent &&
        lhs.home == rhs.home &&
        DateHelper.dayNumber(lhs.fixtureDate) == DateHelper.dayNumber(rhs.fixtureDate) &&
        DateHelper.hourNumber(lhs.fixtureDate) == DateHelper.hourNumber(rhs.fixtureDate)
  }
}
