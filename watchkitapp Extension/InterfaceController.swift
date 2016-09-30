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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InterfaceController.userSettingsUpdated(_:)), name: BaseSettings.SettingsUpdateNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func willActivate() {
        super.willActivate()
        self.setTitle("Yeltzland")
        
        self.updateViewData()
    }
    
    private func updateViewData() {
        let gameSettings = WatchGameSettings.instance
        
        // How many rows?
        let nextFixtures = FixtureManager.instance.GetNextFixtures(6)
        
        let numberOfRows = nextFixtures.count + 1
        
        self.fixtureTable.setNumberOfRows(numberOfRows, withRowType: "FixtureRowType")
        for i in 0...numberOfRows - 1 {
            var opponent: String = ""
            var gameDetails = ""
            var scoreColor = AppColors.WatchTextColor
            
            let row:FixtureRowType = self.fixtureTable.rowControllerAtIndex(i) as! FixtureRowType
            
            if (i == 0) {
                opponent = gameSettings.displayLastOpponent
                gameDetails = gameSettings.lastScore
                
                if (gameSettings.lastGameYeltzScore > gameSettings.lastGameOpponentScore) {
                    scoreColor = AppColors.WatchFixtureWin
                } else if (gameSettings.lastGameYeltzScore == gameSettings.lastGameOpponentScore) {
                    scoreColor = AppColors.WatchFixtureDraw
                } else if (gameSettings.lastGameYeltzScore < gameSettings.lastGameOpponentScore) {
                    scoreColor = AppColors.WatchFixtureLose
                }

            } else {
                if (i == 1 && gameSettings.gameScoreForCurrentGame) {
                    opponent = gameSettings.displayNextOpponent
                    gameDetails = gameSettings.currentScore
                } else if (nextFixtures.count >= i) {
                    opponent = nextFixtures[i - 1].displayOpponent
                    gameDetails = nextFixtures[i - 1].fullKickoffTime
                }
            }
            
            if (opponent.characters.count > 0) {
                row.labelOpponent?.setText(opponent)
                row.labelScore?.setText(gameDetails)
            } else {
                row.labelOpponent?.setText("")
                row.labelScore?.setText("")
            }
            
            // Setup colors
            row.labelOpponent?.setTextColor(AppColors.WatchTextColor)
            row.labelScore?.setTextColor(scoreColor)
        }
    }
    
    @objc
    private func userSettingsUpdated(notification: NSNotification) {
        NSLog("Received Settings updated notification")
        
        // Update view data on main thread
        dispatch_async(dispatch_get_main_queue()) {
            self.updateViewData()
        }
    }
   
}
