//
//  TimelineManager.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

class TimelineManager {
    private var fixtureManager: FixtureManager
    private var gameScoreManager: GameScoreManager
    
    private var lastGames = Array<TimelineEntry>()
    private var currentScore: TimelineEntry?
    private var nextGames = Array<TimelineEntry>()

    required init(fixtureManager: FixtureManager, gameScoreManager: GameScoreManager) {
        self.fixtureManager = fixtureManager
        self.gameScoreManager = gameScoreManager
        
        self.loadLatestData()
    }
    
    public func reloadData() {
        self.loadLatestData()
    }
    
    public var timelineEntries: [TimelineEntry] {
        var firstEntry: TimelineEntry?
        var secondEntry: TimelineEntry?
        
        // Second entry should always be the next fixture if we have it
        secondEntry = self.nextGames.first
        
        // First entry should be the current score if we have it
        firstEntry = currentScore
        
        // Switch the first entry to the last result if empty
        if firstEntry == nil {
            firstEntry = self.lastGames.first
        }
        
        // If we have a 2nd and not 1st, we must have only fixtures, so add the next fixture at the end
        if (firstEntry == nil && secondEntry != nil) {
            firstEntry = secondEntry
            if self.nextGames.count > 1 {
                secondEntry = self.nextGames[1]
            }
        }
        
        var entries: [TimelineEntry] = []
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
        // Get last game details
        self.currentScore = nil

        if let currentFixture = self.gameScoreManager.currentFixture {
            if currentFixture.inProgress {
                self.currentScore = TimelineEntry(
                    opponent: currentFixture.opponent,
                    date: currentFixture.fixtureDate,
                    teamScore: currentFixture.teamScore,
                    opponentScore: currentFixture.opponentScore,
                    status: .inProgress)
           }
        }
        
        self.lastGames.removeAll()
        
        for result in self.fixtureManager.lastResults(2) {
            self.lastGames.append(
                TimelineEntry(
                    opponent: result.opponent,
                    date: result.fixtureDate,
                    teamScore: result.teamScore,
                    opponentScore: result.opponentScore,
                    status: .result))
        }
       
        // Get next games
        self.nextGames.removeAll()
       
        // Only add first fixture if no current game
        var i = 0
        
        for fixture in self.fixtureManager.nextFixtures(2) {
            if (i > 0 || self.currentScore == nil) {
               let fixtureData = TimelineEntry(
                   opponent: fixture.opponent,
                   date: fixture.fixtureDate,
                   teamScore: fixture.teamScore,
                   opponentScore: fixture.opponentScore,
                   status: .fixture)
               self.nextGames.append(fixtureData)
            }
            
            i += 1
        }
   }
}
