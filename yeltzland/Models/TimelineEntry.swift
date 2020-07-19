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

public struct TimelineEntry: Equatable {
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
    
    public static func == (lhs: TimelineEntry, rhs: TimelineEntry) -> Bool {
        return lhs.opponent == rhs.opponent && lhs.date == rhs.date && lhs.home == rhs.home
    }
}
