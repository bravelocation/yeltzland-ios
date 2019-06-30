//
//  FixtureTableViewCell.swift
//  yeltzland
//
//  Created by John Pollard on 17/09/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import UIKit

class FixtureTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    public func assignFixture(_ fixture: Fixture) {
        self.selectionStyle = .none
        self.accessoryType = .none
        
        var resultColor = AppColors.FixtureNone
        
        if (fixture.teamScore == nil || fixture.opponentScore == nil) {
            resultColor = AppColors.FixtureNone
        } else if (fixture.teamScore! > fixture.opponentScore!) {
            resultColor = AppColors.FixtureWin
        } else if (fixture.teamScore! < fixture.opponentScore!) {
            resultColor = AppColors.FixtureLose
        } else {
            resultColor = AppColors.FixtureDraw
        }
        
        // Set main label
        self.teamNameLabel.font = UIFont(name: AppColors.AppFontName, size: AppColors.FixtureTeamSize)!
        self.teamNameLabel.textColor = resultColor
        self.teamNameLabel.adjustsFontSizeToFitWidth = true
        self.teamNameLabel.text = fixture.displayOpponent
        
        // Set detail text
        self.scoreLabel.textColor = resultColor
        self.scoreLabel.adjustsFontSizeToFitWidth = true
        self.scoreLabel.font = UIFont(name: AppColors.AppFontName, size: AppColors.FixtureScoreOrDateTextSize)!
        
        if (fixture.teamScore == nil || fixture.opponentScore == nil) {
            self.scoreLabel.text = fixture.kickoffTime
        } else {
            self.scoreLabel.text = fixture.score
        }
        
        TeamImageManager.instance.loadTeamImage(teamName: fixture.displayOpponent, view: self.logoImage)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
