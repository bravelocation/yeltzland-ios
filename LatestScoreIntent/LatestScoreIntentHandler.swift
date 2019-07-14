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
        
        if let fixture = GameScoreManager.shared.currentFixture {
            var gameState = ""

            if fixture.inProgress {
                gameState = "latest score is"
            } else {
                gameState = "final score was"
            }
 
            let gameDetails = GameDetails(identifier: nil, display: "Game Details")
            gameDetails.opponent = fixture.opponentNoCup
            gameDetails.kickoffTime = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fixture.fixtureDate)
            gameDetails.home = fixture.home as NSNumber
            gameDetails.yeltzScore = NSNumber(value: fixture.teamScore!)
            gameDetails.opponentScore = NSNumber(value: fixture.opponentScore!)
            
            if fixture.home {
                completion(LatestScoreIntentResponse.success(gameState: gameState, gameDetails: gameDetails))
            } else {                
                completion(LatestScoreIntentResponse.successAwayGame(gameState: gameState, gameDetails: gameDetails))
            }
        } else {
            completion(LatestScoreIntentResponse(code: LatestScoreIntentResponseCode.failureNoGames, userActivity: nil))
        }
    }
}
