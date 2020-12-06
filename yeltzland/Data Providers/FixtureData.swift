//
//  FixtureData.swift
//  Yeltzland
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import SDWebImage

#if canImport(SwiftUI)
import SwiftUI
import Combine
#endif

@available(iOS 13.0, *)
class FixtureData: ObservableObject {
    
    enum State {
        case isLoading
        case loaded
    }
    
    @Published var months: [String] = []
    @Published var images: [String: UIImage] = [:]
    @Published var state: State = State.isLoading
    
    init() {
        self.setupNotificationHandlers()
        self.refreshData()
    }
    
    private func setupNotificationHandlers() {
        //Add notification handler for updating on fixtures or score
        NotificationCenter.default.addObserver(self, selector: #selector(FixtureData.dataUpdated(_:)), name: .FixturesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FixtureData.dataUpdated(_:)), name: .GameScoreUpdated, object: nil)
    }
    
    public func refreshData() {
        print("Refreshing fixtures data ...")
        self.setState(.isLoading)
        
        FixtureManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                self.reloadFixtures()
            }
        }
        GameScoreManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                self.reloadFixtures()
            }
        }
    }
    
    private func setState(_ state: State) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
    
    private func reloadFixtures() {
        // Update fixtures data on main thread
        DispatchQueue.main.async {
            self.months = FixtureManager.shared.months

            // Fetch all the team logos
            for month in self.months {
                if let monthlyFixtures = FixtureManager.shared.fixturesForMonth(month) {
                    for fixture in monthlyFixtures {
                        self.fetchTeamImage(fixture: TimelineFixture(
                                                opponent: fixture.opponent,
                                                home: fixture.home,
                                                date: fixture.fixtureDate,
                                                teamScore: fixture.teamScore,
                                                opponentScore: fixture.opponentScore,
                                                status: .fixture))
                    }
                }
            }
            
            self.setState(.loaded)
        }
    }
    
    func monthName(_ month: String) -> String {
        // Find first fixture for month
        if let fixturesForMonth = FixtureManager.shared.fixturesForMonth(month) {
            if let firstMatchInMonth = fixturesForMonth.first {
                return firstMatchInMonth.fixtureMonth
            }
        }
        
        return ""
    }
    
    func teamPic(_ fixture: TimelineFixture) -> Image {
        if let image = self.images[fixture.opponent] {
            return Image(uiImage: image)
        }
        
        return Image("blank_team")
    }
    
    func fixturesForMonth(_ month: String) -> [TimelineFixture] {
        
        var timelineFixtures: [TimelineFixture] = []
        
        let currentFixture = GameScoreManager.shared.currentFixture
        
        if let monthlyFixtures = FixtureManager.shared.fixturesForMonth(month) {
            for fixture in monthlyFixtures {
                var fixtureStatus: TimelineFixtureStatus = .result
                
                if currentFixture == fixture && (currentFixture?.inProgress ?? false) {
                    fixtureStatus = .inProgress
                } else if fixture.teamScore == nil || fixture.opponentScore == nil {
                    fixtureStatus = .fixture
                }
                
                let timelineFixture = TimelineFixture(
                    opponent: fixture.opponent,
                    home: fixture.home,
                    date: fixture.fixtureDate,
                    teamScore: fixture.teamScore,
                    opponentScore: fixture.opponentScore,
                    status: fixtureStatus)
            
                timelineFixtures.append(timelineFixture)
                self.fetchTeamImage(fixture: timelineFixture)
            }
        }
        
        return timelineFixtures
    }
    
    private func fetchTeamImage(fixture: TimelineFixture) {
        // Fetch team image
        if self.images[fixture.opponent] == nil {
            if let teamImageUrl = TeamImageManager.shared.teamImageUrl(teamName: fixture.opponent) {
                self.loadImage(imageUrl: teamImageUrl) { image in
                    if let image = image {
                        self.addImageToCache(key: fixture.opponent, image: image)
                    }
                }
            }
        }
    }
    
    
    private func loadImage(imageUrl: URL, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(with: imageUrl,
                                       options: .continueInBackground,
                                       progress: nil) { image, _, _, _, _, _  in
                                            completion(image)
                                        }
    }
    
    @objc
    fileprivate func dataUpdated(_ notification: Notification) {
        self.reloadFixtures()
    }
    
    private func addImageToCache(key: String, image: UIImage) {
        // Update images on main thread
        DispatchQueue.main.async {
            self.images[key] = image
        }
    }
}
