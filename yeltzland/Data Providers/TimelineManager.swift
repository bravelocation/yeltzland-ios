//
//  TimelineManager.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

class TimelineManager {
    private var fixtureManager: TimelineFixtureProvider
    private var gameScoreManager: TimelineGameScoreProvider
    
    private var lastGame: TimelineFixture?
    private var currentScore: TimelineFixture?
    private var nextGames = Array<TimelineFixture>()

    required init(fixtureManager: TimelineFixtureProvider, gameScoreManager: TimelineGameScoreProvider) {
        self.fixtureManager = fixtureManager
        self.gameScoreManager = gameScoreManager
        
        self.loadLatestData()
    }
    
    public func reloadData() {
        self.loadLatestData()
    }
    
    public var timelineEntries: [TimelineFixture] {
        var firstEntry: TimelineFixture?
        var secondEntry: TimelineFixture?
        
        // 1. Get last game, put it into slot 1
        firstEntry = self.lastGame
        
        // 2. If current game is in progress, put it into slot one
        if let currentGame = self.currentScore {
            firstEntry = currentGame
        }
        
        // 3. Get next fixture
        if self.nextGames.count > 0 {
            let nextGame = self.nextGames[0]
            
            // 1. If it is not the current game
            if nextGame != self.currentScore {
                // If the last game was yesterday or today, put it into slot two, otherwise slot one
                if let lastGame = self.lastGame {
                    if lastGame.daysSinceResult <= 1 {
                        secondEntry = nextGame
                    } else {
                        firstEntry = nextGame
                    }
                } else {
                    firstEntry = nextGame
                }
            }
        }
        
        // 4. Fill up the remaining slots with subsequent fixtures
        if firstEntry == nil {
            if self.nextGames.count > 0 {
                firstEntry = self.nextGames[0]
            }
            if self.nextGames.count > 1 {
                secondEntry = self.nextGames[1]
            }
        } else if secondEntry == nil {
          if self.nextGames.count > 1 {
                secondEntry = self.nextGames[1]
            }
        }
        
        // Return the first and second in an array
        var entries: [TimelineFixture] = []
        if let first = firstEntry {
            entries.append(first)
        }
        if let second = secondEntry {
            entries.append(second)
        }
        
        return entries
    }
    
    // Fetch the latest data
    private func loadLatestData() {
        // Get current score
        self.currentScore = nil

        if let currentFixture = self.gameScoreManager.currentFixture {
            if currentFixture.inProgress {
                self.currentScore = TimelineFixture(
                    opponent: currentFixture.opponent,
                    home: currentFixture.home,
                    date: currentFixture.fixtureDate,
                    teamScore: currentFixture.teamScore,
                    opponentScore: currentFixture.opponentScore,
                    status: .inProgress)
           }
        }
        
        // Get last game details
        self.lastGame = nil
        
        if let lastResult = self.fixtureManager.lastGame {
            self.lastGame = TimelineFixture(
                    opponent: lastResult.opponent,
                    home: lastResult.home,
                    date: lastResult.fixtureDate,
                    teamScore: lastResult.teamScore,
                    opponentScore: lastResult.opponentScore,
                    status: .result)
        }
       
        // Get next games
        self.nextGames.removeAll()

        for fixture in self.fixtureManager.nextFixtures(2) {
           let fixtureData = TimelineFixture(
               opponent: fixture.opponent,
               home: fixture.home,
               date: fixture.fixtureDate,
               teamScore: fixture.teamScore,
               opponentScore: fixture.opponentScore,
            status: fixture.afterKickoff ? .inProgress : .fixture)
           self.nextGames.append(fixtureData)
        }
    }
}
