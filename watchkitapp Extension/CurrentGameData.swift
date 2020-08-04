//
//  NextGameData.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 19/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class CurrentGameData: ObservableObject {
    enum State {
        case isLoading
        case loaded
    }
    
    @Published var latest: TimelineFixture?
    @Published var teamImage: Image = Image("blank_team")
    @Published var state = State.isLoading
    
    var timelineManager: TimelineManager!
    var fixtureManager: TimelineFixtureProvider
    var gameScoreManager: TimelineGameScoreProvider
    
    init(fixtureManager: TimelineFixtureProvider, gameScoreManager: TimelineGameScoreProvider) {
        self.fixtureManager = fixtureManager
        self.gameScoreManager = gameScoreManager
        
        self.timelineManager = TimelineManager(
            fixtureManager: fixtureManager,
            gameScoreManager: gameScoreManager
        )
        
        self.resetData()
    }

    public func refreshData() {
        self.setState(.isLoading)
        
        // Go fetch the latest fixtures and game score, then reload the timeline
        self.fixtureManager.fetchLatestData { result in
            if result == .success(true) {
                self.resetData()
            }
            
            self.gameScoreManager.fetchLatestData { result in
                if result == .success(true) {
                    self.resetData()
                    self.setState(.loaded)
                }
                
                self.setState(.loaded)
            }
        }
    }
    
    var resultColor: Color {
        if let latest = self.latest {
            switch latest.result {
            case .win:
                return Color("watch-fixture-win")
            case .lose:
                return Color("watch-fixture-lose")
            default:
                return Color("light-blue")
            }
        }
        
        return Color("light-blue")
    }
    
    private func setState(_ state: State) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
    
    fileprivate func resetData() {
        self.timelineManager.reloadData()
        
        DispatchQueue.main.async {
            self.latest = self.timelineManager.timelineEntries.first
            
            if let latest = self.latest {
                self.fetchTeamLogo(latest.logoImageName)
            }
        }
    }
    
    fileprivate func fetchTeamLogo(_ teamName: String) {
        TeamImageManager.shared.loadTeamImage(teamName: teamName) { image in
            if let image = image {
                self.teamImage = Image(uiImage: image)
            }
        }
    }
}
