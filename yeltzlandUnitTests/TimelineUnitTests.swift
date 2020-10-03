//
//  yeltzlandUnitTests.swift
//  yeltzlandUnitTests
//
//  Created by John Pollard on 19/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import XCTest

class TimelineUnitTests: XCTestCase {
    
    private let fixtureManager = MockFixtureManager()
    private let gameScoreManager = MockGameScoreManager()
    private var timelineManager: TimelineManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.timelineManager = TimelineManager(fixtureManager: fixtureManager, gameScoreManager: gameScoreManager)
    }

    func testNoFixtureOrGameData() throws {
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 0, "If no data is set up, timeline will have no entries")
    }
    
    func testOnlyResults() throws {
        self.fixtureManager.createResult(daysToAdd: -1, opponent: "Result", home: true, teamScore: 1, opponentScore: 0)
        self.timelineManager.reloadData()
        
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 1, "Should just show last result")
        if let firstEntry = timeline.first {
            XCTAssert(firstEntry.opponent == "Result", "Should just show last result")
        }
    }
    
    func testOnlyFixtures() throws {
        self.fixtureManager.addFixture(daysToAdd: 1, opponent: "First Fixture", home: true)
        self.fixtureManager.addFixture(daysToAdd: 8, opponent: "Second Fixture", home: true)
        self.timelineManager.reloadData()
        
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 2, "Should show both fixtures")
        
        if (timeline.count > 0) {
            let firstEntry = timeline[0]
            XCTAssert(firstEntry.opponent == "First Fixture", "Should show first fixture first, because we only have fixtures")
        }

        if (timeline.count > 1) {
            let secondEntry = timeline[1]
            XCTAssert(secondEntry.opponent == "Second Fixture", "Should show second fixture second, because we only have fixtures")
        }
    }
    
    func testResultTodayWithFixtures() throws {
        self.fixtureManager.createResult(daysToAdd: 0, opponent: "Result", home: true, teamScore: 1, opponentScore: 0)
        self.fixtureManager.addFixture(daysToAdd: 7, opponent: "First Fixture", home: true)
        self.fixtureManager.addFixture(daysToAdd: 14, opponent: "Second Fixture", home: true)
        self.timelineManager.reloadData()
        
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 2, "Should show 2 entries")
        
        if (timeline.count > 0) {
            let firstEntry = timeline[0]
            XCTAssert(firstEntry.opponent == "Result", "Should show result first, because it was today")
        }

        if (timeline.count > 1) {
            let secondEntry = timeline[1]
            XCTAssert(secondEntry.opponent == "First Fixture", "Should show first fixture second")
        }
    }
    
    func testResultYesterdayWithFixtures() throws {
        self.fixtureManager.createResult(daysToAdd: -1, opponent: "Result", home: true, teamScore: 1, opponentScore: 0)
        self.fixtureManager.addFixture(daysToAdd: 7, opponent: "First Fixture", home: true)
        self.fixtureManager.addFixture(daysToAdd: 14, opponent: "Second Fixture", home: true)
        self.timelineManager.reloadData()
        
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 2, "Should show 2 entries")
        
        if (timeline.count > 0) {
            let firstEntry = timeline[0]
            XCTAssert(firstEntry.opponent == "Result", "Should show result first, because it was yesterday")
        }

        if (timeline.count > 1) {
            let secondEntry = timeline[1]
            XCTAssert(secondEntry.opponent == "First Fixture", "Should show first fixture second")
        }
    }
    
    func testResultTwoDaysAgoWithFixtures() throws {
        self.fixtureManager.createResult(daysToAdd: -2, opponent: "Result", home: true, teamScore: 1, opponentScore: 0)
        self.fixtureManager.addFixture(daysToAdd: 7, opponent: "First Fixture", home: true)
        self.fixtureManager.addFixture(daysToAdd: 14, opponent: "Second Fixture", home: true)
        self.timelineManager.reloadData()
        
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 2, "Should show 2 entries")
        
        if (timeline.count > 0) {
            let firstEntry = timeline[0]
            XCTAssert(firstEntry.opponent == "First Fixture", "Should show first fixture first, because result was before yesterday")
        }

        if (timeline.count > 1) {
            let secondEntry = timeline[1]
            XCTAssert(secondEntry.opponent == "Second Fixture", "Should show second fixture second")
        }
    }
    
    func testCurrentGameOnlyFixture() throws {
        self.fixtureManager.addFixture(daysToAdd: 0, opponent: "First Fixture", home: true)
        self.gameScoreManager.createGameScore(daysToAdd: 0, opponent: "First Fixture", home: true, teamScore: 1, opponentScore: 0)
        
        self.timelineManager.reloadData()
        
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 1, "Should show 1 entry, as last game of the season is in progress")
        
        if (timeline.count > 0) {
            let firstEntry = timeline[0]
            XCTAssert(firstEntry.opponent == "First Fixture", "Should show in progress game first")
            XCTAssert(firstEntry.status == .inProgress, "Should show in progress game first")
        }
    }
    
    func testCurrentGameWithFixturesAndResults() throws {
        self.fixtureManager.createResult(daysToAdd: -1, opponent: "Result", home: true, teamScore: 1, opponentScore: 0)
        self.fixtureManager.addFixture(daysToAdd: 0, opponent: "First Fixture", home: true)
        self.fixtureManager.addFixture(daysToAdd: 7, opponent: "Second Fixture", home: true)
        self.gameScoreManager.createGameScore(daysToAdd: 0, opponent: "First Fixture", home: true, teamScore: 1, opponentScore: 0)
        self.timelineManager.reloadData()
        
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 2, "Should show 2 entries")
        
        if (timeline.count > 0) {
            let firstEntry = timeline[0]
            XCTAssert(firstEntry.opponent == "First Fixture", "Should show in progress game first")
            XCTAssert(firstEntry.status == .inProgress, "Should show in progress game first")
        }

        if (timeline.count > 1) {
            let secondEntry = timeline[1]
            XCTAssert(secondEntry.opponent == "Second Fixture", "Should show second fixture second")
            XCTAssert(secondEntry.status == .fixture, "Should show in progress game first")
        }
    }
    
    func testGameHasFinishedWithFixturesAndResults() throws {
        self.fixtureManager.createResult(daysToAdd: 0, opponent: "Result Today", home: true, teamScore: 1, opponentScore: 0)
        self.fixtureManager.addFixture(daysToAdd: 7, opponent: "Second Fixture", home: true)
        self.gameScoreManager.createGameScore(daysToAdd: 0, opponent: "Result Today", home: true, teamScore: 1, opponentScore: 0, inProgress: false)
        self.timelineManager.reloadData()
        
        let timeline = self.timelineManager.timelineEntries
        
        XCTAssert(timeline.count == 2, "Should show 2 entries")
        
        if (timeline.count > 0) {
            let firstEntry = timeline[0]
            XCTAssert(firstEntry.opponent == "Result Today", "Should show in today's result first")
            XCTAssert(firstEntry.status == .result, "Should show in today's result first")
        }

        if (timeline.count > 1) {
            let secondEntry = timeline[1]
            XCTAssert(secondEntry.opponent == "Second Fixture", "Should show second fixture second")
            XCTAssert(secondEntry.status == .fixture, "Should show in progress game first")
        }
    }
}
