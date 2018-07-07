//
//  LatestScoreViewController.swift
//  yeltzland
//
//  Created by John Pollard on 11/06/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class LatestScoreViewController: UIViewController {
    
    @IBOutlet weak var homeOrAwayLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var latestScoreLabel: UILabel!
    @IBOutlet weak var opponentLogoImageView: UIImageView!
    
    var reloadButton: UIBarButtonItem!
    let gameSettings = GameSettings.instance
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotificationWatcher()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setupNotificationWatcher()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Removed notification handler for game score updates")
    }
    
    fileprivate func setupNotificationWatcher() {
        NotificationCenter.default.addObserver(self, selector: #selector(LatestScoreViewController.gameScoreUpdated), name: NSNotification.Name(rawValue: GameScoreManager.GameScoreNotification), object: nil)
        print("Setup notification handler for game score updates")
    }
    
    @objc fileprivate func gameScoreUpdated(_ notification: Notification) {
        print("Game score message received")
        DispatchQueue.main.async(execute: { () -> Void in
            self.updateUI();
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Go get latest fixtures in background
        self.reloadButtonTouchUp()
        
        // Setup navigation
        self.navigationItem.title = "Latest Score"
        
        self.view.backgroundColor = AppColors.OtherBackground
        
        // Setup refresh button
        self.reloadButton = UIBarButtonItem(
            title: "Reload",
            style: .plain,
            target: self,
            action: #selector(LatestScoreViewController.reloadButtonTouchUp)
        )
        self.reloadButton.FAIcon = FAType.FARotateRight
        self.reloadButton.tintColor = AppColors.NavBarTintColor
        self.navigationController?.navigationBar.tintColor = AppColors.NavBarTintColor
        self.navigationItem.rightBarButtonItems = [self.reloadButton]
        
        self.updateUI()
        
        self.setupHandoff()
    }
    
    @objc func reloadButtonTouchUp() {
        GameScoreManager.instance.getLatestGameScore()
    }
    
    func updateUI() {
        var opponentName = ""
        var homeOrAway = "vs"
        var resultColor = AppColors.FixtureNone
        var score = "TBD"
        
        let opponent = self.gameSettings.lastGameTeam
        
        if let homeGame = self.gameSettings.lastGameHome {
            if (homeGame == false) {
                homeOrAway = "at"
            }
        }
        
        // If currently in a game
        if (self.gameSettings.gameScoreForCurrentGame) {
            opponentName = self.gameSettings.nextGameTeam!
            score = " \(self.gameSettings.currentScore)"  // Add a space prefix
        } else if (opponent != nil) {
            // Get the latest result
            let teamScore = self.gameSettings.lastGameYeltzScore
            let opponentScore  = self.gameSettings.lastGameOpponentScore
                
            if (teamScore != nil && opponentScore != nil) {
                if (teamScore! > opponentScore!) {
                    resultColor = AppColors.FixtureWin
                } else if (teamScore! < opponentScore!) {
                    resultColor = AppColors.FixtureLose
                } else {
                    resultColor = AppColors.FixtureDraw
                }
            }
            
            opponentName = self.gameSettings.lastGameTeam!
            score = self.gameSettings.lastScore
        } else {
            // No scores, so use next game rather than show nothing
            opponentName = self.gameSettings.nextGameTeam!
            if let homeGame = self.gameSettings.nextGameHome {
                if (homeGame == false) {
                    homeOrAway = "at"
                }
            }
        }
        
        self.opponentLabel.text = opponentName
        self.homeOrAwayLabel.text = homeOrAway
        self.latestScoreLabel.text = score
        self.latestScoreLabel.textColor = resultColor
        TeamImageManager.instance.loadTeamImage(teamName: opponentName, view: self.opponentLogoImageView)
    }
    
    // - MARK Handoff
    @objc func setupHandoff() {
        // Set activity for handoff
        let activity = NSUserActivity(activityType: "com.bravelocation.yeltzland.latestscore")
        
        // Eligible for handoff
        activity.isEligibleForHandoff = true
        
        // Set the title
        self.title = "Latest Yeltz Score"
        activity.needsSave = true
        
        self.userActivity = activity;
        self.userActivity?.becomeCurrent()
    }
}
