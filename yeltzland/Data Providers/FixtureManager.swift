//
//  FixtureManager.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

public protocol TimelineFixtureProvider {
    func nextFixtures(_ numberOfFixtures: Int) -> [Fixture]
    var lastGame: Fixture? { get }
    func fetchLatestData(completion: ((Result<Bool, JSONDataError>) -> Void)?)
    var allMatches: [Fixture] { get }
}

extension Notification.Name {
    static let FixturesUpdated = Notification.Name(rawValue: "YLZFixtureNotification")
}

public class FixtureManager: CachedJSONData, TimelineFixtureProvider {

    private var fixtureList: [String: [Fixture]] = [:]
    
    var fileName: String
    var remoteURL: URL
    var notificationName: Notification.Name
    var fileCoordinator: NSFileCoordinator

    private static let sharedInstance = FixtureManager(
                                    fileName: "matches.json",
                                    remoteURL: URL(string: "https://bravelocation.com/automation/feeds/matches.json")!,
                                    notificationName: .FixturesUpdated)
                                    
    class var shared: FixtureManager {
        get {
            return sharedInstance
        }
    }
    
    // MARK: - CachedJSONData functions
    
    required init(fileName: String, remoteURL: URL, notificationName: Notification.Name) {
        self.fileName = fileName
        self.remoteURL = remoteURL
        self.notificationName = notificationName
        
        self.fileCoordinator = NSFileCoordinator(filePresenter: nil)
        
        self.loadBundleFileIntoCache() { result in
            switch result {
            case .success:
                self.loadDataFromCache() { loaded in
                    switch loaded {
                    case .success:
                        print("Loaded fixtures from cache")
                    case .failure:
                        print("A problem occurred loading fixtures from cache")
                    }
                }
                
            case .failure:
                print("Couldn't load fixtures from bundle")
            }
        }
    }
    
    func parseJson(_ json: [String: AnyObject]) -> Result<Bool, JSONDataError> {
        guard let matches = json["Matches"] as? Array<AnyObject> else { return .failure(.jsonFormatError)}
        
        var latestFixtures: [String: [Fixture]] = [:]
        
        // Add each fixture into the correct month
        for currentMatch in matches {
            if let match = currentMatch as? [String: AnyObject] {
                if let currentFixture = Fixture(fromJson: match) {
                    if latestFixtures[currentFixture.monthKey] != nil {
                        latestFixtures[currentFixture.monthKey]?.append(currentFixture)
                    } else {
                        latestFixtures[currentFixture.monthKey] = [currentFixture]
                    }
                }
            }
        }
        
        // Sort the fixtures per month
        for currentMonth in Array(latestFixtures.keys) {
            latestFixtures[currentMonth] = latestFixtures[currentMonth]?.sorted(by: { $0.fixtureDate.compare($1.fixtureDate as Date) == .orderedAscending })
        }
        
        // Finally, switch the fixture list with the new fixtures
        self.fixtureList = latestFixtures
        
        return .success(true)
    }
    
    func isValidJson(_ json: [String: AnyObject]) -> Bool {
        return json["Matches"] != nil
    }
    
    // MARK: - Data properties
    
    public var months: [String] {
        var result: [String] = []
        
        if (self.fixtureList.keys.count > 0) {
            result = Array(self.fixtureList.keys).sorted()
        }
        
        return result
    }
    
    public func fixturesForMonth(_ monthKey: String) -> [Fixture]? {
        
        if let monthFixtures = self.fixtureList[monthKey] {
            return monthFixtures
        }
        
        return nil
    }
    
    public func awayGames(_ opponent: String) -> [Fixture] {
        var foundGames: [Fixture] = []
        
        for month in self.months {
            if let monthFixtures = self.fixturesForMonth(month) {
                for fixture in monthFixtures {
                    if (fixture.opponent == opponent && fixture.home == false) {
                        foundGames.append(fixture)
                    }
                }
            }
        }
        
        return foundGames
    }
    
    public var nextGame: Fixture? {
        let fixtures = self.nextFixtures(1)
        
        if (fixtures.count > 0) {
            return fixtures[0]
        }
        
        return nil
    }
    
    // MARK: - TimelineFixtureProvider implementation
    public var allMatches: [Fixture] {
        var fixtures: [Fixture] = []
        
        for month in self.months {
            if let monthFixtures = self.fixturesForMonth(month) {
                for fixture in monthFixtures {
                    fixtures.append(fixture)
                }
            }
        }
        
        return fixtures
    }
    
    public func nextFixtures(_ numberOfFixtures: Int) -> [Fixture] {
        var fixtures: [Fixture] = []
        let currentDayNumber = DateHelper.dayNumber(Date())
        
        for month in self.months {
            if let monthFixtures = self.fixturesForMonth(month) {
                for fixture in monthFixtures {
                    let matchDayNumber = DateHelper.dayNumber(fixture.fixtureDate as Date)
                    
                    // If no score and match is not before today
                    if (fixture.teamScore == nil && fixture.opponentScore == nil && currentDayNumber <= matchDayNumber) {
                        fixtures.append(fixture)
                        
                        if (fixtures.count == numberOfFixtures) {
                            return fixtures
                        }
                    }
                }
            }
        }
        
        return fixtures
    }
    
    public var lastGame: Fixture? {
        var lastCompletedGame: Fixture? = nil
        
        for month in self.months {
            if let monthFixtures = self.fixturesForMonth(month) {
                for fixture in monthFixtures {
                    if (fixture.teamScore != nil && fixture.opponentScore != nil) {
                        lastCompletedGame = fixture
                    } else {
                        return lastCompletedGame
                    }
                }
            }
        }
        
        return lastCompletedGame
    }
}
