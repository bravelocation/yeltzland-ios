//
//  PreviewFixtureManager.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 20/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public class PreviewFixtureManager: TimelineFixtureProvider {

    private var fixtures: [Fixture] = []
    
    init() {
        self.createResult(daysToAdd: -7, opponent: "Barnet", home: false, teamScore: 2, opponentScore: 1)
        self.addFixture(daysToAdd: 0, opponent: "Stourbridge", home: true)
        self.addFixture(daysToAdd: 7, opponent: "Bedford Town", home: false)
     }
    
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
    
    private func addFixture(daysToAdd: Int, opponent: String, home: Bool) {
        self.fixtures.append(Fixture(
            date: PreviewFixtureManager.makeDate(daysToAdd: daysToAdd),
            opponent: opponent,
            home: home,
            teamScore: nil,
            opponentScore: nil,
            inProgress: false))
    }
    
    private func createResult(daysToAdd: Int, opponent: String, home: Bool, teamScore: Int, opponentScore: Int) {
        self.fixtures.append(Fixture(
            date: PreviewFixtureManager.makeDate(daysToAdd: daysToAdd),
            opponent: opponent,
            home: home,
            teamScore: teamScore,
            opponentScore: opponentScore,
            inProgress: false)
        )
    }
    
    // MARK: - TimelineFixtureProvider interface
    public func nextFixtures(_ numberOfFixtures: Int) -> [Fixture] {
        return self.fixtures.filter({ (fixture) -> Bool in
            return fixture.teamScore == nil && fixture.fixtureDate > Date()
        }).sorted { return $0.fixtureDate < $1.fixtureDate }
    }
    
    public var lastGame: Fixture? {
        return self.fixtures.filter({ (fixture) -> Bool in
            return fixture.teamScore != nil
            }).sorted { return $0.fixtureDate < $1.fixtureDate }.last
    }
    
    public func fetchLatestData(completion: ((Result<Bool, JSONDataError>) -> Void)?) {
        if let completion = completion {
            completion(.success(true))
        }
    }
    
    public var allMatches: [Fixture] {
        return self.fixtures.sorted { return $0.fixtureDate < $1.fixtureDate }
    }
}
