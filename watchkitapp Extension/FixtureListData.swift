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
    
    init() {
        //Add notification handler for updating on updated fixtures
        NotificationCenter.default.addObserver(self, selector: #selector(FixtureListData.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
        
        self.fixtures = FixtureManager.shared.allMatches
        
        // Go fetch the latest fixtures
        FixtureManager.shared.fetchLatestData(completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    fileprivate func userSettingsUpdated(_ notification: Notification) {
        // Update fixtures data on main thread
        DispatchQueue.main.async {
            self.fixtures = FixtureManager.shared.allMatches
        }
    }
}
