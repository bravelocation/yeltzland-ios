//
//  NextGameIntentHandler.swift
//  LatestScoreIntent
//
//  Created by John Pollard on 13/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation

class NextGameIntentHandler: NSObject, NextGameIntentHandling {
    func confirm(intent: NextGameIntent, completion: @escaping (NextGameIntentResponse) -> Void) {
        // Update the fixture and game score caches
        GameScoreManager.shared.fetchLatestData(completion: nil)
        FixtureManager.shared.fetchLatestData(completion: nil)
        
        completion(NextGameIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: NextGameIntent, completion: @escaping (NextGameIntentResponse) -> Void) {
        
        let gameDetails = GameDetails(identifier: nil, display: "Game Details")
        
        if let fixture = FixtureManager.shared.nextGame {
            gameDetails.opponent = fixture.opponentNoCup
            gameDetails.kickoffTime = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fixture.fixtureDate)
            gameDetails.displayKickoffTime = fixture.voiceKickoffTime
            
            if fixture.home {
                gameDetails.homeTeam = "Yeltz"
                gameDetails.awayTeam = fixture.opponentNoCup
            } else {
                gameDetails.homeTeam = fixture.opponentNoCup
                gameDetails.awayTeam = "Yeltz"
            }
        }
        
        if gameDetails.opponent?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            completion(NextGameIntentResponse(code: NextGameIntentResponseCode.failureNoGame, userActivity: nil))
        } else {
            completion(NextGameIntentResponse.success(gameDetails: gameDetails))
        }
    }
}
