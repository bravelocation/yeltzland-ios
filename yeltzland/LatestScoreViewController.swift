//
//  LatestScoreViewController.swift
//  yeltzland
//
//  Created by John Pollard on 11/06/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import UIKit
import Intents
import IntentsUI

class LatestScoreViewController: UIViewController, INUIAddVoiceShortcutViewControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var homeOrAwayLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var latestScoreLabel: UILabel!
    @IBOutlet weak var opponentLogoImageView: UIImageView!
    @IBOutlet weak var bestGuessLabel: UILabel!
    
    var reloadButton: UIBarButtonItem!
    
    // MARK: - View event handlers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Go get latest fixtures in background
        self.reloadButtonTouchUp()
        
        // Setup navigation
        self.navigationItem.title = "Latest Score"
        
        self.view.backgroundColor = AppColors.systemBackground
        
        // Setup refresh button
        self.reloadButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(LatestScoreViewController.reloadButtonTouchUp)
        )
        
        self.reloadButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = [self.reloadButton]
        
        self.updateUI()
        
        self.setupHandoff()
        self.addSiriButton()
    }
    
    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(LatestScoreViewController.reloadButtonTouchUp), discoverabilityTitle: "Reload")
        ]
    }
    
    // MARK: - Event handlers
    @objc func reloadButtonTouchUp() {
        FixtureManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                self.gameScoreUpdated()
            }
        }
        
        GameScoreManager.shared.fetchLatestData() { result in
            if result == .success(true) {
                self.gameScoreUpdated()
            }
        }
    }
    
    // MARK: - Helper functions
    private func gameScoreUpdated() {
        print("Game score or fixture message received")
        DispatchQueue.main.async(execute: { () -> Void in
            self.updateUI()
        })
    }

    private func updateUI() {
        var latestFixture: Fixture? = FixtureManager.shared.getLastGame()
        
        if let currentFixture = GameScoreManager.shared.getCurrentFixture {
            if currentFixture.inProgress {
                latestFixture = currentFixture
            }
        }
        
        if latestFixture == nil {
            if let nextFixture = FixtureManager.shared.getNextGame() {
                latestFixture = nextFixture
            }
        }
        
        var homeOrAway = "vs"
        var resultColor = AppColors.label
        var score = "TBD"
        
        if let fixture = latestFixture {
            if (fixture.home == false) {
                homeOrAway = "at"
            }
            
            let teamScore = fixture.teamScore
            let opponentScore = fixture.opponentScore
            
            if (teamScore != nil && opponentScore != nil) {
                score = String(format: "%d-%d%@", teamScore!, opponentScore!, fixture.inProgress ? "*" : "")
                
                if (teamScore! > opponentScore!) {
                    resultColor = UIColor(named: "fixture-win")!
                } else if (teamScore! < opponentScore!) {
                    resultColor = UIColor(named: "fixture-lose")!
                } else {
                    resultColor = UIColor(named: "fixture-draw")!
                }
            }
 
            self.opponentLabel.text = fixture.opponentNoCup
            self.homeOrAwayLabel.text = homeOrAway
            self.latestScoreLabel.text = score
            self.latestScoreLabel.textColor = resultColor
            TeamImageManager.shared.loadTeamImage(teamName: fixture.opponent, view: self.opponentLogoImageView)
            
            self.bestGuessLabel.isHidden = (fixture.inProgress == false)
        }
    }
    
    // MARK: - Handoff
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
        
        self.userActivity = activity
        self.userActivity?.becomeCurrent()
    }
    
    // MARK: - Siri Intents
    func addSiriButton() {
        if #available(iOS 12.0, *) {
            var buttonStyle: INUIAddVoiceShortcutButtonStyle = .whiteOutline
            
            if #available(iOS 13.0, *) {
                buttonStyle = .automaticOutline
            }
            
            let button = INUIAddVoiceShortcutButton(style: buttonStyle)
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
            let intent = ShortcutManager.shared.latestScoreIntent()
            
            if let shortcut = INShortcut(intent: intent) {
                let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                viewController.modalPresentationStyle = .formSheet
                viewController.delegate = self
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - INUIAddVoiceShortcutViewControllerDelegate
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
