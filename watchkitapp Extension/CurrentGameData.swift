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
    
    var logo: UIImage?
    
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
    
    var teamImage: Image {
        if let image = self.logo {
            return Image(uiImage: image)
        }
        
        return Image("blank_team")
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
            if image != nil {
                self.logo = image
            }
        }
    }
}
