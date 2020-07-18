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

public struct TimelineEntry {
    var opponent: String
    var date: Date
    var teamScore: Int?
    var opponentScore: Int?
    var status: TimelineEntryStatus
    
    init(opponent: String, date: Date, teamScore: Int?, opponentScore: Int?, status: TimelineEntryStatus) {
        self.opponent = opponent
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
            let currentDayNumber = FixtureManager.shared.dayNumber(now)
            let fixtureDayNumber = FixtureManager.shared.dayNumber(self.date)
            
            if (currentDayNumber == fixtureDayNumber) {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                
                return formatter.string(from: self.date)
            } else {
                return self.fullKickoffTime
            }
        }
    }
}
