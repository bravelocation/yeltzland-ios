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
    
    var timelineManager: TimelineManager!
    
    init() {
        timelineManager = TimelineManager(
            fixtureManager: FixtureManager.shared,
            gameScoreManager: GameScoreManager.shared
        )
        
        self.resetData()
    }
    
    fileprivate func resetData() {
        self.timelineManager.reloadData()
        DispatchQueue.main.async {
            self.latest = self.timelineManager.timelineEntries.first
        }
    }

    public func refreshData() {
        // Go fetch the latest fixtures and game score, then reload the timeline
        FixtureManager.shared.fetchLatestData { _ in self.resetData() }
        GameScoreManager.shared.fetchLatestData { _ in self.resetData() }
    }
}
