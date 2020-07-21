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
    @Published var title: String = "Yeltzland"
    
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
        self.setTitle("Loading ...")
        
        // Go fetch the latest fixtures and game score, then reload the timeline
        fixtureManager.fetchLatestData { result in
            if result == .success(true) {
                self.resetData()
            }
            
            self.setTitle("Yeltzland")
        }
        
        gameScoreManager.fetchLatestData { result in
            if result == .success(true) {
                self.resetData()
            }
            
            self.setTitle("Yeltzland")
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
    
    private func setTitle(_ titleUpdate: String) {
        DispatchQueue.main.async {
            self.title = titleUpdate
        }
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
