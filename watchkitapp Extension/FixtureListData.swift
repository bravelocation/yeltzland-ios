//
//  FixtureListData.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class FixtureListData: ObservableObject {
    @Published var fixtures: [TimelineEntry] = []
    @Published var results: [TimelineEntry] = []
    @Published var logos: [String: UIImage] = [:]

    var fixtureManager: TimelineFixtureProvider
    var gameScoreManager: TimelineGameScoreProvider
    
    init() {
        self.fixtureManager = FixtureManager.shared
        self.gameScoreManager = GameScoreManager.shared
        
        self.setup()
    }
    
    init(fixtureManager: TimelineFixtureProvider, gameScoreManager: TimelineGameScoreProvider) {
        self.fixtureManager = fixtureManager
        self.gameScoreManager = gameScoreManager
        
        self.setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setup() {
        //Add notification handler for updating on updated fixtures
        NotificationCenter.default.addObserver(self, selector: #selector(FixtureListData.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
        
        self.resetData()
    }
    
    public func refreshData() {
        // Go fetch the latest fixtures and game score, then reload the timeline
        fixtureManager.fetchLatestData { result in
            if result == .success(true) {
                self.resetData()
            }
        }
        
        gameScoreManager.fetchLatestData { result in
            if result == .success(true) {
                self.resetData()
            }
        }
    }
    
    func teamImage(_ teamName: String) -> Image {
        if let image = self.logos[teamName] {
            return Image(uiImage: image)
        }
        
        return Image("blank_team")
    }
    
    func resultColor(_ fixture: TimelineEntry) -> Color {
        switch fixture.result {
        case .win:
            return Color("watch-fixture-win")
        case .lose:
            return Color("watch-fixture-lose")
        default:
            return Color.white
        }
    }
    
    fileprivate func fetchTeamLogo(_ teamName: String) {
        if self.logos[teamName] != nil {
            return
        }
        
        TeamImageManager.shared.loadTeamImage(teamName: teamName) { image in
            if image != nil {
                self.logos[teamName] = image
            }
        }
    }
    
    fileprivate func resetData() {
        var newFixtures: [TimelineEntry] = []
        var newResults: [TimelineEntry] = []

        for fixture in self.fixtureManager.allMatches {
            if fixture.teamScore == nil && fixture.opponentScore == nil {
                newFixtures.append(
                    TimelineEntry(opponent: fixture.opponent,
                                  home: fixture.home,
                                  date: fixture.fixtureDate,
                                  teamScore: fixture.teamScore,
                                  opponentScore: fixture.opponentScore,
                                  status: .fixture)
                )
            } else {
                newResults.append(
                    TimelineEntry(opponent: fixture.opponent,
                                  home: fixture.home,
                                  date: fixture.fixtureDate,
                                  teamScore: fixture.teamScore,
                                  opponentScore: fixture.opponentScore,
                                  status: .result)
                )
            }
            
            self.fetchTeamLogo(fixture.opponentNoCup)
        }
        
        self.fetchTeamLogo("Halesowen Town")
        
        self.fixtures = newFixtures
        self.results = newResults.reversed()
    }
    
    @objc
    fileprivate func userSettingsUpdated(_ notification: Notification) {
        // Update fixtures data on main thread
        DispatchQueue.main.async {
            self.resetData()
        }
    }
}
