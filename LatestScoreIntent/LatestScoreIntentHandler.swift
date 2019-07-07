//
//  LatestScoreIntentHandler.swift
//  LatestScoreIntent
//
//  Created by John Pollard on 22/09/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import Foundation

class LatestScoreIntentHandler: NSObject, LatestScoreIntentHandling {
    func confirm(intent: LatestScoreIntent, completion: @escaping (LatestScoreIntentResponse) -> Void) {
        // Update the fixture and game score caches
        GameScoreManager.shared.fetchLatestData(completion: nil)
        FixtureManager.shared.fetchLatestData(completion: nil)

        completion(LatestScoreIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: LatestScoreIntent, completion: @escaping (LatestScoreIntentResponse) -> Void) {
        var homeTeamName = ""
        var awayTeamName = ""
        var gameState = ""
        var homeTeamScore: Int = 0
        var awayTeamScore: Int = 0
        
        if let fixture = GameScoreManager.shared.currentFixture {
            // If currently in a game
            if fixture.inProgress {
                gameState = "latest score is"
            } else {
                gameState = "final score was"
            }
            
            if fixture.home {
                homeTeamName = "Yeltz"
                awayTeamName = fixture.opponentNoCup
                homeTeamScore = fixture.teamScore!
                awayTeamScore = fixture.opponentScore!
            } else {
                homeTeamName = fixture.opponentNoCup
                awayTeamName = "Yeltz"
                homeTeamScore = fixture.opponentScore!
                awayTeamScore = fixture.teamScore!
            }

        }
        
        if homeTeamName.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 || awayTeamName.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            completion(LatestScoreIntentResponse(code: LatestScoreIntentResponseCode.failureNoGames, userActivity: nil))
        } else {
            completion(LatestScoreIntentResponse.success(gameState: gameState,
                                                         homeTeam: homeTeamName,
                                                         homeScore: String(homeTeamScore),
                                                         awayTeam: awayTeamName,
                                                         awayScore: String(awayTeamScore)))
        }
    }
}
