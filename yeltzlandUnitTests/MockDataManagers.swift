//
//  MockDataManagers.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public class MockFixtureManager: TimelineFixtureProvider {

    private var fixtures: [Fixture] = []
    private var result: Fixture?
    
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
    
    public func clearAll() {
        self.fixtures.removeAll()
        self.result = nil
    }
    
    public func addFixture(daysToAdd: Int, opponent: String, home: Bool) {
        self.fixtures.append(Fixture(
            date: MockFixtureManager.makeDate(daysToAdd: daysToAdd),
            opponent: opponent,
            home: home,
            teamScore: nil,
            opponentScore: nil,
            inProgress: false))
    }
    
    public func createResult(daysToAdd: Int, opponent: String, home: Bool, teamScore: Int, opponentScore: Int) {
        self.result = Fixture(
            date: MockFixtureManager.makeDate(daysToAdd: daysToAdd),
            opponent: opponent,
            home: home,
            teamScore: teamScore,
            opponentScore: opponentScore,
            inProgress: false)
    }
    
    // MARK: - TimelineFixtureProvider interface
    public func nextFixtures(_ numberOfFixtures: Int) -> [Fixture] {
        return self.fixtures.sorted { return $0.fixtureDate < $1.fixtureDate }
    }
    
    public var lastGame: Fixture? {
        return self.result
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

public class MockGameScoreManager: TimelineGameScoreProvider {
    private var gameScore: Fixture?
    
    public func clearGameScore () {
        self.gameScore = nil
    }
    
    public func createGameScore(daysToAdd: Int, opponent: String, home: Bool, teamScore: Int, opponentScore: Int, inProgress: Bool = true) {
        self.gameScore = Fixture(
            date: MockFixtureManager.makeDate(daysToAdd: daysToAdd),
            opponent: opponent,
            home: home,
            teamScore: teamScore,
            opponentScore: opponentScore,
            inProgress: inProgress)
    }
    
    // MARK: - TimelineGameScoreProvider interface
    public var currentFixture: Fixture? {
        return self.gameScore
    }
    
    public func fetchLatestData(completion: ((Result<Bool, JSONDataError>) -> Void)?) {
        if let completion = completion {
            completion(.success(true))
        }
    }
}
