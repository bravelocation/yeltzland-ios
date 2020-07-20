//
//  TimelineEntry.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public enum TimelineEntryStatus {
    case result
    case inProgress
    case fixture
}

public enum TimelineEntryResult {
    case win
    case draw
    case lose
    case notFinished
}

public struct TimelineEntry: Equatable, Hashable {
    var opponent: String
    var home: Bool
    var date: Date
    var teamScore: Int?
    var opponentScore: Int?
    var status: TimelineEntryStatus
    
    init(opponent: String, home: Bool, date: Date, teamScore: Int?, opponentScore: Int?, status: TimelineEntryStatus) {
        self.opponent = opponent
        self.home = home
        self.date = date
        self.teamScore = teamScore
        self.opponentScore = opponentScore
        self.status = status
    }
    
    var fullKickoffTime: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE dd MMM HH:mm"
            
            return formatter.string(from: self.date)
        }
    }
    
    var fullDisplayKickoffTime: String {
        get {
            // Is the game today?
            let now = Date()
            let currentDayNumber = FixtureManager.dayNumber(now)
            let fixtureDayNumber = FixtureManager.dayNumber(self.date)
            
            if (currentDayNumber == fixtureDayNumber) {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                
                return formatter.string(from: self.date)
            } else {
                return self.fullKickoffTime
            }
        }
    }
    
    var displayScore: String {
        get {
            if let teamScore = self.teamScore, let opponentScore = self.opponentScore {
                 return "\(teamScore)-\(opponentScore)"
            }
        
            return ""
        }
    }
    
    var displayOpponent: String {
        get {
            if (self.home) {
                return "\(self.opponent.uppercased()) (H)"
            } else {
                return "\(self.opponent) (A)"
            }
        }
    }
    
    var result: TimelineEntryResult {
        if let teamScore = self.teamScore, let opponentScore = self.opponentScore {
            if teamScore > opponentScore {
                return .win
            } else if teamScore == opponentScore {
                return .draw
            } else {
                return .lose
            }
        }
        
        return .notFinished
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
    
    public static func == (lhs: TimelineEntry, rhs: TimelineEntry) -> Bool {
        return lhs.opponent == rhs.opponent && lhs.date == rhs.date && lhs.home == rhs.home
    }
}
