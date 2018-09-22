//
//  LatestScoreViewController.swift
//  yeltzland
//
//  Created by John Pollard on 11/06/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import Intents
import IntentsUI

class LatestScoreViewController: UIViewController, INUIAddVoiceShortcutViewControllerDelegate {
    
    // MARK:- Properties
    @IBOutlet weak var homeOrAwayLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var latestScoreLabel: UILabel!
    @IBOutlet weak var opponentLogoImageView: UIImageView!
    @IBOutlet weak var bestGuessLabel: UILabel!
    
    var reloadButton: UIBarButtonItem!
    let gameSettings = GameSettings.instance
    
    // MARK:- Initialisation
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
        NotificationCenter.default.addObserver(self, selector: #selector(LatestScoreViewController.gameScoreUpdated), name: NSNotification.Name(rawValue: FixtureManager.FixturesNotification), object: nil)
        print("Setup notification handler for game score updates")
    }
    
    @objc fileprivate func gameScoreUpdated(_ notification: Notification) {
        print("Game score or fixture message received")
        DispatchQueue.main.async(execute: { () -> Void in
            self.updateUI();
        })
    }
    
    // MARK:- View event handlers
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
        self.addSiriButton()
    }
    
    // MARK:- Event handlers
    @objc func reloadButtonTouchUp() {
        GameScoreManager.instance.getLatestGameScore()
    }
    
    // MARK:- Helper functions
    private func updateUI() {
        var opponentName = ""
        var homeOrAway = "vs"
        var resultColor = AppColors.FixtureNone
        var score = "TBD"
        var bestGuess = self.gameSettings.gameScoreForCurrentGame
        
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
        } else if (self.gameSettings.currentGameState() == .duringNoScore) {
            opponentName = self.gameSettings.nextGameTeam!
            score = " 0-0*"  // Add a space prefix
            bestGuess = true
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
        
        self.bestGuessLabel.isHidden = (bestGuess == false)
    }
    
    // MARK:- Handoff
    @objc func setupHandoff() {
        // Set activity for handoff
        let activity = NSUserActivity(activityType: "com.bravelocation.yeltzland.latestscore")
        
        // Eligible for handoff
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.title = "Latest Yeltz Score"

        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
            activity.suggestedInvocationPhrase = "Latest Yeltz Score"
            activity.persistentIdentifier = String(format: "%@.com.bravelocation.yeltzland.latestscore", Bundle.main.bundleIdentifier!)
        }
        
        // Set the title
        activity.needsSave = true
        
        self.userActivity = activity;
        self.userActivity?.becomeCurrent()
    }
    
    // MARK :_ Siri Intents
    func addSiriButton() {
        if #available(iOS 12.0, *) {
            let button = INUIAddVoiceShortcutButton(style: .whiteOutline)
            button.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(button)
            button.addTarget(self, action: #selector(addToSiri(_:)), for: .touchUpInside)

            self.view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
            self.latestScoreLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -32.0).isActive = true
        }
    }
    
    @objc
    func addToSiri(_ sender: Any) {
        if #available(iOS 12.0, *) {
            let intent = LatestScoreIntent()
            intent.suggestedInvocationPhrase = "What's the latest score"
            
            if let shortcut = INShortcut(intent: intent) {
                let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                viewController.modalPresentationStyle = .formSheet
                viewController.delegate = self
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK:- INUIAddVoiceShortcutViewControllerDelegate
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        print("Added shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        print("Cancelled shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
}
