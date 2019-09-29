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
        
        if let fixture = FixtureManager.shared.nextGame {
            let response = NextGameIntentResponse.success(opponent: fixture.opponentNoCup, kickoffTime: fixture.voiceKickoffTime)
            
            let gameDetails = GameDetails(identifier: nil, display: fixture.opponentNoCup)
            gameDetails.home = fixture.home ? 1 : 0
            gameDetails.kickoffTime = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fixture.fixtureDate)
            gameDetails.opponent = fixture.opponentNoCup
            
            response.gameDetails = gameDetails
            
            completion(response)
        } else {
            completion(NextGameIntentResponse(code: NextGameIntentResponseCode.failureNoGame, userActivity: nil))
        }
    }
}
