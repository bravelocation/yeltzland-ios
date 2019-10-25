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
    @Published var latest: Fixture? = nil
    @Published var logos: [String: UIImage] = [:]
    
    init() {
        //Add notification handler for updating on updated fixtures
        NotificationCenter.default.addObserver(self, selector: #selector(FixtureListData.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
        
        self.fixtures = FixtureManager.shared.allMatches
        self.latest = self.calculateLatestFixture()
        self.cacheAllLogos()
        
        // Go fetch the latest fixtures and game score
        self.refreshData()
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
    
    fileprivate func cacheAllLogos() {
        self.fetchTeamLogo("Halesowen Town")
        
        for fixture in self.fixtures where self.logos[fixture.opponentNoCup] == nil {
            self.fetchTeamLogo(fixture.opponentNoCup)
        }
    }
    
    fileprivate func fetchTeamLogo(_ teamName: String) {
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
    
    @objc
    fileprivate func userSettingsUpdated(_ notification: Notification) {
        // Update fixtures data on main thread
        DispatchQueue.main.async {
            self.fixtures = FixtureManager.shared.allMatches
            self.latest = self.calculateLatestFixture()
            self.cacheAllLogos()
        }
    }
}
