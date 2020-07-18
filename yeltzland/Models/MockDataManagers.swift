//
//  MockDataManagers.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public class MockFixtureManager: TimelineFixtureProvider {
    static func makeDate(daysToAdd: Int) -> Date {
        // Get today at 1500
        let dateCurrent = Date()
        var components = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: dateCurrent)
        
        components.hour = 15
        components.minute = 0
        
        let baseDate = Calendar.current.date(from: components)
        
        var addComponents = DateComponents()
        addComponents.day = daysToAdd
        return Calendar.current.date(byAdding: addComponents, to: baseDate!)!
    }
    
    public func nextFixtures(_ numberOfFixtures: Int) -> [Fixture] {
        var fixtures: [Fixture] = []
        
        fixtures.append(Fixture(date: MockFixtureManager.makeDate(daysToAdd: 1), opponent: "Stourbridge", home: true, teamScore: nil, opponentScore: nil, inProgress: false))
        fixtures.append(Fixture(date: MockFixtureManager.makeDate(daysToAdd: 3), opponent: "Barnet", home: true, teamScore: nil, opponentScore: nil, inProgress: false))
        
        return fixtures
    }
    
    public func lastResults(_ numberOfFixtures: Int) -> [Fixture] {
        var results: [Fixture] = []
        
        results.append(Fixture(date: MockFixtureManager.makeDate(daysToAdd: -7), opponent: "Concord Rangers", home: true, teamScore: 2, opponentScore: 0, inProgress: false))
        results.append(Fixture(date: MockFixtureManager.makeDate(daysToAdd: -4), opponent: "Halifax Town", home: true, teamScore: 3, opponentScore: 1, inProgress: false))
        
        return results.reversed()
    }
}

public class MockGameScoreManager: TimelineGameScoreProvider {
    public var currentFixture: Fixture? {
        return nil
        return Fixture(date: MockFixtureManager.makeDate(daysToAdd: 0), opponent: "Stourbridge", home: true, teamScore: 4, opponentScore: 0, inProgress: true)
    }
}
