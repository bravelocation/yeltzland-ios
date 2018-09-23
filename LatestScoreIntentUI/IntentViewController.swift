//
//  IntentViewController.swift
//  LatestScoreIntentUI
//
//  Created by John Pollard on 22/09/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    // Mark:- Properties
    
    @IBOutlet weak var gameStateLabel: UILabel!
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamScoreLabel: UILabel!
    @IBOutlet weak var awayTeamScoreLabel: UILabel!
    
    let gameSettings = GameSettings.instance
    
    // Mark :- View event handlers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.gameStateLabel.textColor = AppColors.SiriIntentText
        self.homeTeamNameLabel.textColor = AppColors.SiriIntentText
        self.awayTeamNameLabel.textColor = AppColors.SiriIntentText
        self.homeTeamScoreLabel.textColor = AppColors.SiriIntentText
        self.awayTeamScoreLabel.textColor = AppColors.SiriIntentText
        
        self.gameStateLabel.font = UIFont(name: AppColors.AppFontName, size:AppColors.SiriIntentTextSize)!
        self.homeTeamNameLabel.font = UIFont(name: AppColors.AppFontName, size:AppColors.SiriIntentTextSize)!
        self.awayTeamNameLabel.font = UIFont(name: AppColors.AppFontName, size:AppColors.SiriIntentTextSize)!
        self.homeTeamScoreLabel.font = UIFont(name: AppColors.AppFontName, size:AppColors.SiriIntentTextSize)!
        self.awayTeamScoreLabel.font = UIFont(name: AppColors.AppFontName, size:AppColors.SiriIntentTextSize)!
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        
        guard interaction.intent is LatestScoreIntent else {
            completion(false, Set(), .zero)
            return
        }
        
        var homeTeamName = ""
        var awayTeamName = ""
        var gameState = ""
        var homeTeamScore = 0
        var awayTeamScore = 0
        
        if let fixture = self.gameSettings.getLatestFixtureFromSettings() {
            // If currently in a game
            if fixture.inProgress {
                gameState = "The latest score is ..."
            }  else {
                gameState = "The final score was ..."
            }
            
            if fixture.home {
                homeTeamName = "Yeltz"
                awayTeamName = fixture.opponent
                homeTeamScore = fixture.teamScore!
                awayTeamScore = fixture.opponentScore!
            } else {
                homeTeamName = fixture.opponent
                awayTeamName = "Yeltz"
                homeTeamScore = fixture.opponentScore!
                awayTeamScore = fixture.teamScore!
            }
        } else {
            completion(false, Set(), .zero)
            return
        }
        
        self.gameStateLabel.text = gameState
        self.homeTeamNameLabel.text = homeTeamName
        self.awayTeamNameLabel.text = awayTeamName
        self.homeTeamScoreLabel.text = String(format: "%d", homeTeamScore)
        self.awayTeamScoreLabel.text = String(format: "%d", awayTeamScore)
        
        let homeTeamForImage = homeTeamName == "Yeltz" ? "Halesowen Town" : homeTeamName
        let awayTeamForImage = awayTeamName == "Yeltz" ? "Halesowen Town" : awayTeamName

        TeamImageManager.instance.loadTeamImage(teamName: homeTeamForImage, view: self.homeTeamImage)
        TeamImageManager.instance.loadTeamImage(teamName: awayTeamForImage, view: self.awayTeamImage)

        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        return CGSize(width: self.extensionContext?.hostedViewMaximumAllowedSize.width ?? 320.00, height: 120.0)
    }
}
