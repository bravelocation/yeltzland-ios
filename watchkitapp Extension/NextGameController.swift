//
//  NextGameController.swift
//  yeltzland
//
//  Created by John Pollard on 10/06/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import WatchKit
import Foundation
import SDWebImage

class NextGameController: WKInterfaceController {

    @IBOutlet var nextGameTitle: WKInterfaceLabel!
    @IBOutlet var nextGameOpponent: WKInterfaceLabel!
    @IBOutlet var nextGameDate: WKInterfaceLabel!
    @IBOutlet var nextGameFootnote: WKInterfaceLabel!
    @IBOutlet var homeTeamLogoImage: WKInterfaceImage!
    @IBOutlet var awayTeamLogoImage: WKInterfaceImage!

    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(NextGameController.userSettingsUpdated(_:)), name: NSNotification.Name(rawValue: BaseSettings.SettingsUpdateNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func willActivate() {
        super.willActivate()
        
        self.updateViewData()
    }
    
    fileprivate func updateViewData() {
        let gameSettings = WatchGameSettings.instance
        
        var homeTeamName = ""
        var awayTeamName = ""
        
        if (gameSettings.gameScoreForCurrentGame) {
            self.nextGameTitle?.setText("Latest Score")
            self.nextGameOpponent?.setText(gameSettings.displayNextOpponent)
            self.nextGameDate?.setText(gameSettings.currentScore)
            self.nextGameFootnote?.setText("*best guess from Twitter")
            
            if let home = gameSettings.nextGameHome {
                if home {
                    homeTeamName = "Halesowen Town"
                    awayTeamName = gameSettings.displayNextOpponent
                } else {
                    homeTeamName = gameSettings.displayNextOpponent
                    awayTeamName = "Halesowen Town"
                }
            }
        } else {
            // Was the last game today?
            let todayNumber = gameSettings.dayNumber(Date())
            if (gameSettings.lastGameTime != nil && gameSettings.dayNumber(gameSettings.lastGameTime!) == todayNumber) {
                // Calculate score color
                var scoreColor = AppColors.WatchTextColor
                if (gameSettings.lastGameYeltzScore != nil && gameSettings.lastGameOpponentScore != nil) {
                    if (gameSettings.lastGameYeltzScore! > gameSettings.lastGameOpponentScore!) {
                        scoreColor = AppColors.WatchFixtureWin
                    } else if (gameSettings.lastGameYeltzScore! == gameSettings.lastGameOpponentScore!) {
                        scoreColor = AppColors.WatchFixtureDraw
                    } else if (gameSettings.lastGameYeltzScore! < gameSettings.lastGameOpponentScore!) {
                        scoreColor = AppColors.WatchFixtureLose
                    }
                }
                
                self.nextGameDate?.setTextColor(scoreColor)
                
                self.nextGameTitle?.setText("Result")
                self.nextGameOpponent?.setText(gameSettings.displayLastOpponent)
                self.nextGameDate?.setText(gameSettings.lastScore)
                self.nextGameFootnote?.setText("")
                
                if let home = gameSettings.lastGameHome {
                    if home {
                        homeTeamName = "Halesowen Town"
                        awayTeamName = gameSettings.displayLastOpponent
                    } else {
                        homeTeamName = gameSettings.displayLastOpponent
                        awayTeamName = "Halesowen Town"
                    }
                }
            } else {
                // Show next fixture if there is one
                let nextFixtures = FixtureManager.instance.GetNextFixtures(1)
                if (nextFixtures.count > 0) {
                    let fixture = nextFixtures[0];
                    
                    self.nextGameTitle?.setText("Next Game")
                    self.nextGameOpponent?.setText(fixture.displayOpponent)
                    self.nextGameDate?.setText(fixture.fullKickoffTime)
                    self.nextGameFootnote?.setText("")
                    
                    if fixture.home {
                        homeTeamName = "Halesowen Town"
                        awayTeamName = fixture.displayOpponent
                    } else {
                        homeTeamName = fixture.displayOpponent
                        awayTeamName = "Halesowen Town"
                    }
                } else {
                    self.nextGameTitle?.setText("No more games")
                    self.nextGameOpponent?.setText("")
                    self.nextGameDate?.setText("")
                    self.nextGameFootnote?.setText("")
                }
            }
        }
        
        if (homeTeamName.count > 0) {
            TeamImageManager.instance.loadTeamImage(teamName: homeTeamName, view: self.homeTeamLogoImage)
        }
        if (awayTeamName.count > 0) {
            TeamImageManager.instance.loadTeamImage(teamName: awayTeamName, view: self.awayTeamLogoImage)
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
