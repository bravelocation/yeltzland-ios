//
//  InterfaceController.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var fixtureTable: WKInterfaceTable!
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(InterfaceController.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func willActivate() {
        super.willActivate()
        self.setTitle("Next games")
        
        self.updateViewData()
    }
    
    fileprivate func updateViewData() {
        let nextFixtures = FixtureManager.instance.GetNextFixtures(6)
        
        self.fixtureTable.setNumberOfRows(nextFixtures.count, withRowType: "FixtureRowType")
        for i in 0...nextFixtures.count - 1 {
            
            let row:FixtureRowType = self.fixtureTable.rowController(at: i) as! FixtureRowType
            row.labelOpponent?.setText(nextFixtures[i].displayOpponent)
            row.labelScore?.setText(nextFixtures[i].fullKickoffTime)
            
            row.labelOpponent?.setTextColor(AppColors.WatchTextColor)
            row.labelScore?.setTextColor(AppColors.WatchTextColor)
        }
    }
    
    @objc
    fileprivate func userSettingsUpdated(_ notification: Notification) {
        print("Received Settings updated notification")
        
        // Update view data on main thread
        DispatchQueue.main.async {
            self.updateViewData()
        }
    }
}
