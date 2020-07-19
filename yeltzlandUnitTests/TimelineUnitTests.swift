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
}
