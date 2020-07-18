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
}
