//
//  FixtureManager.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

public class FixtureManager: CachedJSONData {

    private var fixtureList: [String: [Fixture]] = [:]
    
    var fileName: String
    var remoteURL: URL
    var notificationName: String
    var fileCoordinator: NSFileCoordinator

    private static let sharedInstance = FixtureManager(
                                    fileName: "matches.json",
                                    remoteURL: URL(string: "https://bravelocation.com/automation/feeds/matches.json")!,
                                    notificationName: "YLZFixtureNotification")
                                    
    class var shared: FixtureManager {
        get {
            return sharedInstance
        }
    }
    
    // MARK: - CachedJSONData functions
    
    required init(fileName: String, remoteURL: URL, notificationName: String) {
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
    
    public func getAwayGames(_ opponent: String) -> [Fixture] {
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
    
    public func fixtureCount() -> Int {
        var fixtureCount = 0
        
        for month in self.months {
            if let monthFixtures = self.fixturesForMonth(month) {
                fixtureCount += monthFixtures.count
            }
        }
        
        return fixtureCount

    }
    
    public func getLastGame() -> Fixture? {
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
    
    public func getNextGame() -> Fixture? {
        let fixtures = self.getNextFixtures(1)
        
        if (fixtures.count > 0) {
            return fixtures[0]
        }
        
        return nil
    }
    
    public func getNextFixtures(_ numberOfFixtures: Int) -> [Fixture] {
        var fixtures: [Fixture] = []
        let currentDayNumber = self.dayNumber(Date())
        
        for month in self.months {
            if let monthFixtures = self.fixturesForMonth(month) {
                for fixture in monthFixtures {
                    let matchDayNumber = self.dayNumber(fixture.fixtureDate as Date)
                    
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
    
    public func getAllMatches() -> [Fixture] {
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
    
    public func getCurrentGame() -> Fixture? {
        let nextGame = self.getNextGame()
        
        if (nextGame != nil) {
            // If within 120 minutes of kickoff date, the game is current
            let now = Date()
            let differenceInMinutes = (Calendar.current as NSCalendar).components(.minute, from: nextGame!.fixtureDate as Date, to: now, options: []).minute
            
            if (differenceInMinutes! >= 0 && differenceInMinutes! < 120) {
                return nextGame
            }
        }
        
        return nil
    }
    
    public func dayNumber(_ date: Date) -> Int {
        // Removes the time components from a date
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.day, .month, .year]
        let startOfDayComponents = (calendar as NSCalendar).components(unitFlags, from: date)
        let startOfDay = calendar.date(from: startOfDayComponents)
        let intervalToStaryOfDay = startOfDay!.timeIntervalSince1970
        let daysDifference = floor(intervalToStaryOfDay) / 86400  // Number of seconds per day = 60 * 60 * 24 = 86400
        return Int(daysDifference)
    }
}
