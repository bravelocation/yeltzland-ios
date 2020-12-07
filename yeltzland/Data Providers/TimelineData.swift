//
//  TimelineData.swift
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
class TimelineData: ObservableObject {
    
    enum State {
        case isLoading
        case loaded
    }
    
    @Published var fixtures: [TimelineFixture] = []
    @Published var images: [String: UIImage] = [:]
    @Published var state: State = State.isLoading
    
    var timelineManager: TimelineManager
    
    init() {
        self.timelineManager = TimelineManager(fixtureManager: FixtureManager.shared, gameScoreManager: GameScoreManager.shared)
        
        self.setupNotificationHandlers()
        self.refreshData()
    }
    
    private func setupNotificationHandlers() {
        //Add notification handler for updating on fixtures or score
        NotificationCenter.default.addObserver(self, selector: #selector(TimelineData.dataUpdated(_:)), name: .FixturesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TimelineData.dataUpdated(_:)), name: .GameScoreUpdated, object: nil)
    }
    
    public func refreshData() {
        print("Refreshing timeline data ...")
        self.setState(.isLoading)
        
        FixtureManager.shared.fetchLatestData() { _ in
            self.timelineManager.reloadData()
            self.reloadFixtures()
        }
        GameScoreManager.shared.fetchLatestData() { _ in
            self.timelineManager.reloadData()
            self.reloadFixtures()
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
            self.fixtures = self.timelineManager.timelineEntries

            // Fetch all the team logos
            for fixture in self.fixtures {
                self.fetchTeamImage(fixture: fixture)
            }
            
            self.setState(.loaded)
        }
    }
    
    func teamPic(_ fixture: TimelineFixture) -> Image {
        if let image = self.images[fixture.opponent] {
            return Image(uiImage: image)
        }
        
        return Image("blank_team")
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
