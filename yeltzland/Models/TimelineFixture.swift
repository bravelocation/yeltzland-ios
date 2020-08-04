//
//  TimelineFixture.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public enum TimelineFixtureStatus {
    case result
    case inProgress
    case fixture
}

public enum TimelineFixtureResult {
    case win
    case draw
    case lose
    case notFinished
}

public struct TimelineFixture: Equatable, Hashable {
    var opponent: String
    var home: Bool
    var date: Date
    var teamScore: Int?
    var opponentScore: Int?
    var status: TimelineFixtureStatus
    
    init(opponent: String, home: Bool, date: Date, teamScore: Int?, opponentScore: Int?, status: TimelineFixtureStatus) {
        self.opponent = opponent
        self.home = home
        self.date = date
        self.teamScore = teamScore
        self.opponentScore = opponentScore
        self.status = status
    }

    var result: TimelineFixtureResult {
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
    
    public static func == (lhs: TimelineFixture, rhs: TimelineFixture) -> Bool {
        return lhs.opponent == rhs.opponent && lhs.date == rhs.date && lhs.home == rhs.home
    }
}
