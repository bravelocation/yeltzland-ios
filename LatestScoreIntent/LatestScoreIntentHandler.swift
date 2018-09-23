//
//  LatestScoreIntentHandler.swift
//  LatestScoreIntent
//
//  Created by John Pollard on 22/09/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import Foundation

class LatestScoreIntentHandler: NSObject, LatestScoreIntentHandling {
    let gameSettings = GameSettings.instance
    
    func confirm(intent: LatestScoreIntent, completion: @escaping (LatestScoreIntentResponse) -> Void) {
        // Update the fixture and game score caches
        GameScoreManager.instance.getLatestGameScore()
        FixtureManager.instance.getLatestFixtures()

        completion(LatestScoreIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: LatestScoreIntent, completion: @escaping (LatestScoreIntentResponse) -> Void) {
        var homeTeamName = ""
        var awayTeamName = ""
        var gameState = ""
        var homeTeamScore = 0
        var awayTeamScore = 0
        
        if let fixture = self.gameSettings.getLatestFixtureFromSettings() {
            // If currently in a game
            if fixture.inProgress {
                gameState = "latest score is"
            }  else {
                gameState = "final score was"
            }
            
            if fixture.home {
                homeTeamName = "Yeltz"
                awayTeamName = fixture.opponent
                homeTeamScore = fixture.teamScore!
                awayTeamScore = fixture.opponentScore!
            } else {
                homeTeamName = fixture.opponent
                awayTeamName = "Yeltz"
                homeTeamScore = fixture.opponentScore!
                awayTeamScore = fixture.teamScore!
            }

        } else {
            completion(LatestScoreIntentResponse(code: LatestScoreIntentResponseCode.failureNoGames, userActivity: nil))
            return
        }

        completion(LatestScoreIntentResponse.success(gameState: gameState,
                                                     homeTeam: homeTeamName,
                                                     homeScore: NSNumber(value: homeTeamScore),
                                                     awayTeam: awayTeamName,
                                                     awayScore: NSNumber(value: awayTeamScore)))
    }
}

