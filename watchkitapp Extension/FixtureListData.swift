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
    @Published var fixtures: [Fixture] = []
    @Published var results: [Fixture] = []
    @Published var latest: Fixture? = nil
    @Published var logos: [String: UIImage] = [:]
    
    init() {
        //Add notification handler for updating on updated fixtures
        NotificationCenter.default.addObserver(self, selector: #selector(FixtureListData.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
        
        self.resetData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func refreshData() {
        // Go fetch the latest fixtures and game score
        FixtureManager.shared.fetchLatestData(completion: nil)
        GameScoreManager.shared.fetchLatestData(completion: nil)
    }
    
    func teamImage(_ teamName: String) -> Image {
        if let image = self.logos[teamName] {
            return Image(uiImage: image)
        }
        
        return Image("blank_team")
    }
    
    func resultColor(_ fixture: Fixture?) -> Color {
        guard let fixture = fixture else {
            return Color.white
        }
        
        let teamScore = fixture.teamScore
        let opponentScore  = fixture.opponentScore
         
        if (teamScore != nil && opponentScore != nil) {
             if (teamScore! > opponentScore!) {
                return Color("watch-fixture-win")
             } else if (teamScore! < opponentScore!) {
                return Color("watch-fixture-lose")
             }
        }
        
        return Color.white
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
    
    fileprivate func calculateLatestFixture() -> Fixture? {
        var latestFixture: Fixture? = FixtureManager.shared.lastGame

        if let currentFixture = GameScoreManager.shared.currentFixture {
            if currentFixture.inProgress {
                latestFixture = currentFixture
            }
        }
        
        return latestFixture
    }
    
    fileprivate func resetData() {
        var newFixtures: [Fixture] = []
        var newResults: [Fixture] = []

        for fixture in FixtureManager.shared.allMatches {
            if fixture.teamScore == nil && fixture.opponentScore == nil {
                newFixtures.append(fixture)
            } else {
                newResults.append(fixture)
            }
            
            self.fetchTeamLogo(fixture.opponentNoCup)
        }
        
        self.fetchTeamLogo("Halesowen Town")
        
        self.fixtures = newFixtures
        self.results = newResults

        self.latest = self.calculateLatestFixture()
    }
    
    @objc
    fileprivate func userSettingsUpdated(_ notification: Notification) {
        // Update fixtures data on main thread
        DispatchQueue.main.async {
            self.resetData()
        }
    }
}
