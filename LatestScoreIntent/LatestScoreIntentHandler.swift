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

        let opponent = self.gameSettings.lastGameTeam
        
        // If currently in a game
        if (self.gameSettings.gameScoreForCurrentGame) {
            if let nextGameHome = self.gameSettings.nextGameHome {
                if nextGameHome {
                    homeTeamName = "Yeltz"
                    awayTeamName = self.gameSettings.nextGameTeam!
                    homeTeamScore = self.gameSettings.currentYeltzScore
                    awayTeamScore = self.gameSettings.currentOpponentScore
                } else {
                    homeTeamName = self.gameSettings.nextGameTeam!
                    awayTeamName = "Yeltz"
                    homeTeamScore = self.gameSettings.currentOpponentScore
                    awayTeamScore = self.gameSettings.currentYeltzScore
                }
            }
            
            gameState = "latest score is"
        } else if (gameSettings.currentGameState() == .duringNoScore) {
            if let nextGameHome = self.gameSettings.nextGameHome {
                if nextGameHome {
                    homeTeamName = "Yeltz"
                    awayTeamName = self.gameSettings.nextGameTeam!
                    homeTeamScore = 0
                    awayTeamScore = 0
                } else {
                    homeTeamName = self.gameSettings.nextGameTeam!
                    awayTeamName = "Yeltz"
                    homeTeamScore = 0
                    awayTeamScore = 0
                }
            }
            
            gameState = "latest score is"
        } else if (opponent != nil) {
            // Get the latest result
            if let lastGameHome = self.gameSettings.lastGameHome {
                if lastGameHome {
                    homeTeamName = "Yeltz"
                    awayTeamName = self.gameSettings.lastGameTeam!
                    homeTeamScore = self.gameSettings.lastGameYeltzScore!
                    awayTeamScore = self.gameSettings.lastGameOpponentScore!
                } else {
                    homeTeamName = self.gameSettings.lastGameTeam!
                    awayTeamName = "Yeltz"
                    homeTeamScore = self.gameSettings.lastGameOpponentScore!
                    awayTeamScore = self.gameSettings.lastGameYeltzScore!
                }
            }
            
            gameState = "final score was"
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

