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
    // MARK: - Properties
    
    @IBOutlet weak var gameStateLabel: UILabel!
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamScoreLabel: UILabel!
    @IBOutlet weak var awayTeamScoreLabel: UILabel!
    
    // Mark :- View event handlers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.gameStateLabel.textColor = AppColors.label
        self.homeTeamNameLabel.textColor = AppColors.label
        self.awayTeamNameLabel.textColor = AppColors.label
        self.homeTeamScoreLabel.textColor = AppColors.label
        self.awayTeamScoreLabel.textColor = AppColors.label
        
        self.gameStateLabel.font = UIFont(name: AppFonts.AppFontName, size: AppFonts.SiriIntentTextSize)!
        self.homeTeamNameLabel.font = UIFont(name: AppFonts.AppFontName, size: AppFonts.SiriIntentTextSize)!
        self.awayTeamNameLabel.font = UIFont(name: AppFonts.AppFontName, size: AppFonts.SiriIntentTextSize)!
        self.homeTeamScoreLabel.font = UIFont(name: AppFonts.AppFontName, size: AppFonts.SiriIntentTextSize)!
        self.awayTeamScoreLabel.font = UIFont(name: AppFonts.AppFontName, size: AppFonts.SiriIntentTextSize)!
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        
        var fixture: Fixture?
        
        if interaction.intent is LatestScoreIntent {
            fixture = GameScoreManager.shared.currentFixture
        } else if interaction.intent is NextGameIntent {
            fixture = FixtureManager.shared.nextGame
        }
        
        var homeTeamName = ""
        var awayTeamName = ""
        var gameState = ""
        var homeTeamScore = ""
        var awayTeamScore = ""
        
        if let fixture = fixture {
            if fixture.inProgress {
                gameState = "The latest score is ..."
            } else if interaction.intent is NextGameIntent {
                gameState = "The next game is at \(fixture.fullDisplayKickoffTime)..."
            } else {
                gameState = "The final score was ..."
            }
            
            if fixture.home {
                homeTeamName = "Yeltz"
                awayTeamName = fixture.opponentNoCup
            } else {
                homeTeamName = fixture.opponentNoCup
                awayTeamName = "Yeltz"
            }
            
            if let teamScore = fixture.teamScore {
                if fixture.home {
                    homeTeamScore = String(format: "%d", teamScore)
                } else {
                    awayTeamScore = String(format: "%d", teamScore)
                }
            }
            
            if let opponentScore = fixture.opponentScore {
                if fixture.home {
                    awayTeamScore = String(format: "%d", opponentScore)
                } else {
                    homeTeamScore = String(format: "%d", opponentScore)
                }
            }
        } else {
            completion(false, Set(), .zero)
            return
        }
        
        self.gameStateLabel.text = gameState
        self.homeTeamNameLabel.text = homeTeamName
        self.awayTeamNameLabel.text = awayTeamName
        self.homeTeamScoreLabel.text = homeTeamScore
        self.awayTeamScoreLabel.text = awayTeamScore
        
        let homeTeamForImage = homeTeamName == "Yeltz" ? "Halesowen Town" : homeTeamName
        let awayTeamForImage = awayTeamName == "Yeltz" ? "Halesowen Town" : awayTeamName

        TeamImageManager.shared.loadTeamImage(teamName: homeTeamForImage, view: self.homeTeamImage)
        TeamImageManager.shared.loadTeamImage(teamName: awayTeamForImage, view: self.awayTeamImage)

        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        return CGSize(width: self.extensionContext?.hostedViewMaximumAllowedSize.width ?? 320.00, height: 120.0)
    }
}
