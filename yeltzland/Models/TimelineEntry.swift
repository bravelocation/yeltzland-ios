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
    
    public static func == (lhs: TimelineEntry, rhs: TimelineEntry) -> Bool {
        return lhs.opponent == rhs.opponent && lhs.date == rhs.date && lhs.home == rhs.home
    }
}
