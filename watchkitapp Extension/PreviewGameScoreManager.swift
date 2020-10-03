//
//  PreviewGameScoreManager.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 20/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public class PreviewGameScoreManager: TimelineGameScoreProvider {
    private var gameScore: Fixture?
    
    init() {
        self.createGameScore(daysToAdd: 0, opponent: "Stourbridge", home: true, teamScore: 3, opponentScore: 0)
    }
    
    public func createGameScore(daysToAdd: Int, opponent: String, home: Bool, teamScore: Int, opponentScore: Int) {
        self.gameScore = Fixture(
            date: PreviewFixtureManager.makeDate(daysToAdd: daysToAdd),
            opponent: opponent,
            home: home,
            teamScore: teamScore,
            opponentScore: opponentScore)
    }
    
    // MARK: - TimelineGameScoreProvider interface
    public var currentFixture: Fixture? {
        return self.gameScore
    }
    
    public func fetchLatestData(completion: ((Result<Bool, JSONDataError>) -> Void)?) {
        if let completion = completion {
            completion(.success(true))
        }
    }
}
