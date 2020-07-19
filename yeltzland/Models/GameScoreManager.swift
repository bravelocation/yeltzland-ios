//
//  GameScoreManager.swift
//  yeltzland
//
//  Created by John Pollard on 28/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

public protocol TimelineGameScoreProvider {
    var currentFixture: Fixture? { get }
}

public class GameScoreManager: CachedJSONData, TimelineGameScoreProvider {
    var fileName: String
    var remoteURL: URL
    var notificationName: String
    var fileCoordinator: NSFileCoordinator
    
    fileprivate static let sharedInstance = GameScoreManager(fileName: "gamescore.json",
                                                             remoteURL: URL(string: "https://bravelocation.com/automation/feeds/gamescore.json")!,
                                                             notificationName: "YLZGameScoreNotification")
    class var shared: GameScoreManager {
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
                        print("Loaded game score from cache")
                    case .failure:
                         print("A problem occurred loading game score from cache")
                    }
                }
                
            case .failure:
                print("Couldn't load game score from bundle")
            }
        }
    }
    
    func parseJson(_ json: [String: AnyObject]) -> Result<Bool, JSONDataError> {
        // Clear settings
        var parsedFixture: Fixture? = nil
        var yeltzScore: Int = 0
        var opponentScore: Int = 0
        
        if let currentMatch = json["match"] {
            if let fixture = Fixture(fromJson: currentMatch as! [String: AnyObject]) {
                parsedFixture = fixture
            }
        }

        if let parsedYeltzScore = json["yeltzScore"] as? String {
            yeltzScore = Int(parsedYeltzScore)!
        }
        
        if let parsedOpponentScore = json["opponentScore"] as? String {
            opponentScore = Int(parsedOpponentScore)!
        }
        
        if let fixture = parsedFixture {
            // Is the game in progress?
            
            if let nextFixture = FixtureManager.shared.nextGame {
                if (FixtureManager.dayNumber(nextFixture.fixtureDate) == FixtureManager.dayNumber(fixture.fixtureDate)) {
                    // If current score is on same day as next fixture, then we are in progress
                    self.currentFixture = Fixture(date: fixture.fixtureDate,
                                                  opponent: fixture.opponent,
                                                  home: fixture.home,
                                                  teamScore: yeltzScore,
                                                  opponentScore: opponentScore,
                                                  inProgress: true)
                } else {
                    let now = Date()
                    let afterKickoff = now.compare(nextFixture.fixtureDate) == ComparisonResult.orderedDescending
                    
                    if (afterKickoff) {
                        // If after kickoff, we are in progress with no score yet
                        self.currentFixture = Fixture(date: nextFixture.fixtureDate,
                                                      opponent: nextFixture.opponent,
                                                      home: nextFixture.home,
                                                      teamScore: 0,
                                                      opponentScore: 0,
                                                      inProgress: true)
                    } else if let lastResult = FixtureManager.shared.lastGame {
                        // Otherwise "latest score" must be last result
                        self.currentFixture = lastResult
                    }
                    
                }
            }
            
            return .success(true)
        } else {
            return .failure(.jsonFormatError)
        }
    }
    
    func isValidJson(_ json: [String: AnyObject]) -> Bool {
        return json["match"] != nil
    }
    
    // MARK: - TimelineGameScoreProvider implementation
    public var currentFixture: Fixture?
}
