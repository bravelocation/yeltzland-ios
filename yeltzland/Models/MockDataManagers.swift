//
//  MockDataManagers.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public class MockFixtureManager: TimelineFixtureProvider {
    func makeDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: dateString)!
    }
    
    public func nextFixtures(_ numberOfFixtures: Int) -> [Fixture] {
        var fixtures: [Fixture] = []
        
        fixtures.append(Fixture(date: makeDate("2020/10/10 15:00"), opponent: "Stourbridge Town", home: true, teamScore: nil, opponentScore: nil, inProgress: false))
        fixtures.append(Fixture(date: makeDate("2020/10/14 19:45"), opponent: "Harrogate Town", home: true, teamScore: nil, opponentScore: nil, inProgress: false))
        
        return fixtures
    }
    
    public func lastResults(_ numberOfFixtures: Int) -> [Fixture] {
        var results: [Fixture] = []
        
        results.append(Fixture(date: makeDate("2020/10/03 15:00"), opponent: "Concord Rangers", home: true, teamScore: 2, opponentScore: 0, inProgress: false))
        results.append(Fixture(date: makeDate("2020/10/07 19:45"), opponent: "Lye Town", home: true, teamScore: 3, opponentScore: 1, inProgress: false))
        
        return results.reversed()
    }
}

public class MockGameScoreManager: TimelineGameScoreProvider {
    func makeDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: dateString)!
    }
    
    public var currentFixture: Fixture? {
        return Fixture(date: makeDate("2020/10/10 15:00"), opponent: "Stourbridge Town", home: true, teamScore: 4, opponentScore: 0, inProgress: true)
    }
}
