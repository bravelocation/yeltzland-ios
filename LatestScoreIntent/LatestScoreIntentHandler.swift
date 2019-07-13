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
        
        let gameDetails = GameDetails(identifier: nil, display: "Game Details")
        
        if let fixture = GameScoreManager.shared.currentFixture {
            // If currently in a game
            if fixture.inProgress {
                gameDetails.gameState = "latest score is"
            } else {
                gameDetails.gameState = "final score was"
            }
            
            if fixture.home {
                gameDetails.homeTeam = "Yeltz"
                gameDetails.awayTeam = fixture.opponentNoCup
                gameDetails.homeScore = NSNumber(value: fixture.teamScore!)
                gameDetails.awayScore =  NSNumber(value: fixture.opponentScore!)
            } else {
                gameDetails.homeTeam = fixture.opponentNoCup
                gameDetails.awayTeam = "Yeltz"
                gameDetails.homeScore = NSNumber(value: fixture.opponentScore!)
                gameDetails.awayScore = NSNumber(value: fixture.teamScore!)
            }
            
            gameDetails.opponent = fixture.opponentNoCup
            gameDetails.kickoffTime = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fixture.fixtureDate)
            gameDetails.displayKickoffTime = fixture.voiceKickoffTime
        }
        
        if gameDetails.homeTeam?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 || gameDetails.awayTeam?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            completion(LatestScoreIntentResponse(code: LatestScoreIntentResponseCode.failureNoGames, userActivity: nil))
        } else {
            completion(LatestScoreIntentResponse.success(gameDetails: gameDetails))
        }
    }
}
