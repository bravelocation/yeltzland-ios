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
import WidgetKit

class LatestScoreViewController: UIViewController, INUIAddVoiceShortcutViewControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var homeOrAwayLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var latestScoreLabel: UILabel!
    @IBOutlet weak var opponentLogoImageView: UIImageView!
    @IBOutlet weak var bestGuessLabel: UILabel!
    
    var reloadButton: UIBarButtonItem!
    
    // MARK: - Initialisation
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotificationWatcher()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setupNotificationWatcher()
    }
    
    fileprivate func setupNotificationWatcher() {
        NotificationCenter.default.addObserver(self, selector: #selector(LatestScoreViewController.gameScoreUpdated), name: .GameScoreUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LatestScoreViewController.gameScoreUpdated), name: .FixturesUpdated, object: nil)
        print("Setup notification handler for game score updates")
    }
    
    @objc fileprivate func gameScoreUpdated() {
        print("Game score or fixture message received")
        DispatchQueue.main.async(execute: { () -> Void in
            self.updateUI()
        })
    }
    
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
        
        self.addSiriButton()
    }
    
    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
         if #available(iOS 13.0, *) {
            return [
                UIKeyCommand(title: "Reload", action: #selector(LatestScoreViewController.reloadButtonTouchUp), input: "R", modifierFlags: .command),
            ]
         } else {
            return [
                UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(LatestScoreViewController.reloadButtonTouchUp), discoverabilityTitle: "Reload"),
            ]
        }
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
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
                
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }
    
    // MARK: - Helper functions

    private func updateUI() {
        let timelineManager = TimelineManager(fixtureManager: FixtureManager.shared, gameScoreManager: GameScoreManager.shared)
        timelineManager.reloadData()
        
        let entries = timelineManager.timelineEntries
        let latestFixture: TimelineFixture? = entries.first
        
        var homeOrAway = "vs"
        var resultColor = AppColors.label
        var score = ""
        
        if let fixture = latestFixture {
            if (fixture.home == false) {
                homeOrAway = "at"
            }
            
            let teamScore = fixture.teamScore
            let opponentScore = fixture.opponentScore
            
            if (teamScore != nil && opponentScore != nil) {
                score = String(format: "%d-%d%@", teamScore!, opponentScore!, fixture.status == .inProgress ? "*" : "")
                
                if (teamScore! > opponentScore!) {
                    resultColor = UIColor(named: "fixture-win")!
                } else if (teamScore! < opponentScore!) {
                    resultColor = UIColor(named: "fixture-lose")!
                } else {
                    resultColor = UIColor(named: "fixture-draw")!
                }
            } else {
                score = fixture.kickoffTime
            }
 
            if self.opponentLabel == nil {
                // UI not loaded
                return
            }
            
            self.opponentLabel.text = fixture.opponent
            self.homeOrAwayLabel.text = homeOrAway
            self.latestScoreLabel.text = score
            self.latestScoreLabel.textColor = resultColor
            TeamImageManager.shared.loadTeamImage(teamName: fixture.opponent, view: self.opponentLogoImageView)
            
            self.bestGuessLabel.isHidden = (fixture.status != .inProgress)
        }
    }
    
    // MARK: - Siri Intents
    func addSiriButton() {
        var buttonStyle: INUIAddVoiceShortcutButtonStyle = .whiteOutline
        
        if #available(iOS 13.0, *) {
            buttonStyle = .automaticOutline
        }
        
        let button = INUIAddVoiceShortcutButton(style: buttonStyle)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(addToSiri(_:)), for: .touchUpInside)

        self.view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 16.0).isActive = true
    }
    
    @objc
    func addToSiri(_ sender: Any) {
        let intent = ShortcutManager.shared.latestScoreIntent()
        
        if let shortcut = INShortcut(intent: intent) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.modalPresentationStyle = .formSheet
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - INUIAddVoiceShortcutViewControllerDelegate
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        print("Added shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        print("Cancelled shortcut")
        controller.dismiss(animated: true, completion: nil)
    }
}
