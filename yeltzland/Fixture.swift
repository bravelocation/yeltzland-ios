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

public enum FixtureState {
    case manyDaysBefore
    case daysBefore
    case gameDayBefore
    case during
    case after
    case dayAfter
    case manyDaysAfter
}


public class Fixture {
    var fixtureDate: Date
    var opponent: String
    var home: Bool
    var teamScore: Int?
    var opponentScore: Int?
    var inProgress:Bool = false
    
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
    
    init(date: Date, opponent:String, home:Bool, teamScore: Int?, opponentScore: Int?, inProgress:Bool) {
        self.fixtureDate = date
        self.opponent = opponent
        self.home = home
        self.teamScore = teamScore
        self.opponentScore = opponentScore
        self.inProgress = inProgress
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

    var fullDisplayKickoffTime : String {
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
                return self.fullKickoffTime
            }
        }
    }
    
    var tvFixtureDisplayKickoffTime : String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "HHmm"
            
            return String.init(format: "%@ at %@", self.fullKickoffTime, formatter.string(from: self.fixtureDate))
        }
    }
    
    var tvResultDisplayKickoffTime : String {
        get {
            // Is the game today?
            let now = Date()
            let currentDayNumber = FixtureManager.instance.dayNumber(now)
            let fixtureDayNumber = FixtureManager.instance.dayNumber(self.fixtureDate)
            
            if (currentDayNumber == fixtureDayNumber) {
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
    
    public var smallOpponent: String {
        get {
            return self.truncateTeamName(self.opponent, max: 4)
        }
    }
    
    
    public var opponentNoCup: String {
        // Do we have a bracket in the name
        let bracketPos = self.opponent.index(of: "(")
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
    
    var smallScore: String {
        get {
            if ((self.teamScore == nil) || (self.opponentScore == nil)) {
                return ""
            }
            
            return String.init(format: "%d-%d", self.teamScore!, self.opponentScore!)
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
    
    public var smallScoreOrDate: String {
        get {
            switch self.state {
            case .manyDaysBefore:
                let formatter = DateFormatter()
                formatter.dateFormat = "d"
                return formatter.string(from: self.fixtureDate)
            case .daysBefore:
                let formatter = DateFormatter()
                formatter.dateFormat = "E"
                return formatter.string(from: self.fixtureDate)
            case .gameDayBefore:
                let formatter = DateFormatter()
                formatter.dateFormat = "HHmm"
                return formatter.string(from: self.fixtureDate)
            case .during:
                return self.inProgressScore
            case .after, .dayAfter, .manyDaysAfter:
                return self.smallScore
            }
        }
    }
    
    public var fullScoreOrDate: String {
        get {
            switch self.state {
            case .manyDaysBefore, .daysBefore:
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE dd MMM"
                return formatter.string(from: self.fixtureDate)
            case .gameDayBefore:
                let formatter = DateFormatter()
                formatter.dateFormat = "HHmm"
                return formatter.string(from: self.fixtureDate)
            case .during:
                return self.inProgressScore
            case .after, .dayAfter, .manyDaysAfter:
                return self.score
            }
        }
    }
    
    public var truncateOpponent: String {
        get {
            return self.truncateTeamName(self.opponent, max:16)
        }
    }
    
    public var fullTitle: String {
        get {
            switch self.state {
            case .manyDaysBefore, .daysBefore, .gameDayBefore:
                return "Next game:"
            case .during:
                return "Current score"
            case .after, .dayAfter, .manyDaysAfter:
                return "Last game:"
            }
        }
    }
    
    var state: FixtureState {
        get {
            // If in progress
            if (self.inProgress) {
                return FixtureState.during
            }
            
            let now = Date()
            let beforeKickoff = now.compare(self.fixtureDate) == ComparisonResult.orderedAscending
            let todayDayNumber = FixtureManager.instance.dayNumber(now)
            let fixtureDayNumber = FixtureManager.instance.dayNumber(self.fixtureDate)
            
            // If next game is today, and we are before kickoff ...
            if (todayDayNumber == fixtureDayNumber) {
                if beforeKickoff {
                    return FixtureState.gameDayBefore
                }
            }
         
            // If before day today
            if (fixtureDayNumber > todayDayNumber + 7) {
                return FixtureState.manyDaysBefore
            } else if (fixtureDayNumber >  todayDayNumber) {
                return FixtureState.daysBefore
            }

            // If today or yesterday
            if ((fixtureDayNumber == todayDayNumber - 1) || (fixtureDayNumber == todayDayNumber)) {
                return FixtureState.dayAfter
            } else {
                return FixtureState.manyDaysAfter
            }
        }
    }
    
    private func truncateTeamName(_ original: String, max: Int) -> String {
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
