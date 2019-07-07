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
    
    @IBAction func refreshTap() {
        FixtureManager.shared.fetchLatestData(completion: nil)
        GameScoreManager.shared.getLatestGameScore()
    }
    
    override func willActivate() {
        super.willActivate()
        
        self.updateViewData()
    }
    
    fileprivate func updateViewData() {

        var latestFixture: Fixture? = FixtureManager.shared.getLastGame()
        var homeTeamName = ""
        var awayTeamName = ""
        
        if let currentFixture = GameScoreManager.shared.getCurrentFixture {
            if currentFixture.inProgress {
                latestFixture = currentFixture
            }
        }
        
        if let fixture = latestFixture {
            self.nextGameOpponent?.setText(fixture.opponent)
            
            if fixture.home {
                homeTeamName = "Halesowen Town"
                awayTeamName = fixture.opponent
            } else {
                homeTeamName = fixture.opponent
                awayTeamName = "Halesowen Town"
            }

            if (fixture.inProgress) {
                self.nextGameTitle?.setText("Latest Score")
                self.nextGameDate?.setText(fixture.inProgressScore)
                self.nextGameFootnote?.setText("*best guess from Twitter")
            } else {
                self.nextGameTitle?.setText("Final Score")
                self.nextGameDate?.setText(fixture.score)
                self.nextGameFootnote?.setText("")

            }
        } else {
            // Show next fixture if there is one
            let nextFixtures = FixtureManager.shared.getNextFixtures(1)
            if (nextFixtures.count > 0) {
                let fixture = nextFixtures[0]
                
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
        
        if (homeTeamName.count > 0) {
            TeamImageManager.shared.loadTeamImage(teamName: homeTeamName, view: self.homeTeamLogoImage)
        }
        if (awayTeamName.count > 0) {
            TeamImageManager.shared.loadTeamImage(teamName: awayTeamName, view: self.awayTeamLogoImage)
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
