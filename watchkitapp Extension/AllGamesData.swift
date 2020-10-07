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

class AllGamesData: ObservableObject {
    enum State {
        case isLoading
        case loaded
    }
    
    @Published var games: [TimelineFixture] = []
    @Published var logos: [String: UIImage] = [:]
    @Published var title: String = ""
    @Published var state = State.isLoading

    var fixtureManager: TimelineFixtureProvider
    var gameScoreManager: TimelineGameScoreProvider
    var useResults: Bool
    
    init(useResults: Bool) {
        self.fixtureManager = FixtureManager.shared
        self.gameScoreManager = GameScoreManager.shared
        self.useResults = useResults
        
        self.setup()
    }
    
    init(fixtureManager: TimelineFixtureProvider, gameScoreManager: TimelineGameScoreProvider, useResults: Bool) {
        self.fixtureManager = fixtureManager
        self.gameScoreManager = gameScoreManager
        self.useResults = useResults
        
        self.setup()
    }
    
    private func setup() {
        if self.useResults {
            self.title = "Results"
        } else {
            self.title = "Fixtures"
        }
        
        //Add notification handler for updating on updated fixtures
        NotificationCenter.default.addObserver(self, selector: #selector(AllGamesData.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
        
        self.resetData()
    }
    
    public func refreshData() {
        self.setState(.isLoading)
        print("Refreshing watch game data ...")
        
        // Go fetch the latest fixtures and game score, then reload the timeline
        self.fixtureManager.fetchLatestData { result in
            if result == .success(true) {
                self.resetData()
            }
            
            self.gameScoreManager.fetchLatestData { result in
                if result == .success(true) {
                    self.resetData()
                }
                
                self.setState(.loaded)
            }
        }
    }
    
    func teamImage(_ teamName: String) -> Image {
        if let image = self.logos[teamName] {
            return Image(uiImage: image)
        }
        
        return Image("blank_team")
    }
    
    func resultColor(_ fixture: TimelineFixture) -> Color {
        switch fixture.result {
        case .win:
            return Color("watch-fixture-win")
        case .lose:
            return Color("watch-fixture-lose")
        default:
            return Color("watch-fixture-draw")
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
    
    private func setState(_ state: State) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
    
    fileprivate func resetData() {
        var newFixtures: [TimelineFixture] = []
        var newResults: [TimelineFixture] = []

        for fixture in self.fixtureManager.allMatches {
            if fixture.teamScore == nil && fixture.opponentScore == nil {
                newFixtures.append(
                    TimelineFixture(opponent: fixture.opponent,
                                  home: fixture.home,
                                  date: fixture.fixtureDate,
                                  teamScore: fixture.teamScore,
                                  opponentScore: fixture.opponentScore,
                                  status: .fixture)
                )
            } else {
                newResults.append(
                    TimelineFixture(opponent: fixture.opponent,
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
        
        DispatchQueue.main.async {
            if (self.useResults) {
                self.games = newResults.reversed()
            } else {
                self.games = newFixtures
            }
        }
    }
    
    @objc
    fileprivate func userSettingsUpdated(_ notification: Notification) {
        // Update fixtures data on main thread
        DispatchQueue.main.async {
            self.resetData()
        }
    }
}
