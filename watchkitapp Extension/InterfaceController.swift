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
        self.updateViewData()
    }
    
    
    @IBAction func refreshTouchUp() {
        FixtureManager.instance.getLatestFixtures()
    }
    
    fileprivate func updateViewData() {
        // A row per month, plus for each fixture
        self.fixtureTable.setNumberOfRows(FixtureManager.instance.Months.count + FixtureManager.instance.fixtureCount(), withRowType: "FixtureRowType")

        // Get each month in turn
        var rowCount = 0
        var firstFixtureRow = 0
        
        for month in FixtureManager.instance.Months {
            let fixturesForMonth = FixtureManager.instance.FixturesForMonth(month)
            
            if (fixturesForMonth == nil || fixturesForMonth!.count == 0) {
                continue
            }
             
            // Then add all the fixtures
            for i in 0...fixturesForMonth!.count - 1 {
                let fixture = fixturesForMonth![i]
                let row:FixtureRowType = self.fixtureTable.rowController(at: rowCount) as! FixtureRowType
                
                var resultColor = AppColors.WatchTextColor

                if (fixture.teamScore == nil && fixture.opponentScore == nil) {
                     // Mark this fixture
                    if (firstFixtureRow <= 0) {
                        firstFixtureRow = rowCount
                    }
                } else {
                    let teamScore = fixture.teamScore
                    let opponentScore  = fixture.opponentScore
                    
                    if (teamScore != nil && opponentScore != nil) {
                        if (teamScore! > opponentScore!) {
                            resultColor = AppColors.WatchFixtureWin
                        } else if (teamScore! < opponentScore!) {
                            resultColor = AppColors.WatchFixtureLose
                        } else {
                            resultColor = AppColors.WatchFixtureDraw
                        }
                    }
                }
                
                row.loadFixture(fixture, resultColor: resultColor)

                rowCount = rowCount + 1
            }
        }
        
        // Scroll to first fixture
        self.fixtureTable.scrollToRow(at: firstFixtureRow)
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
