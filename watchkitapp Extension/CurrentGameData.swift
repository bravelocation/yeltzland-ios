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
    @Published var latest: TimelineEntry?
    @Published var teamImage: Image = Image("blank_team")
    
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
        // Go fetch the latest fixtures and game score, then reload the timeline
        fixtureManager.fetchLatestData { _ in self.resetData() }
        gameScoreManager.fetchLatestData { _ in self.resetData() }
    }
    
    fileprivate func resetData() {
        self.timelineManager.reloadData()
        DispatchQueue.main.async {
            self.latest = self.timelineManager.timelineEntries.first
            
            if let latest = self.latest {
                self.fetchTeamLogo(latest.opponentNoCup)
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
