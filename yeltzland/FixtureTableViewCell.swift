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
        if #available(iOS 13.0, *) {
            self.backgroundColor = .systemBackground
        }
        
        var resultColor = AppColors.label
        
        if (fixture.teamScore == nil || fixture.opponentScore == nil) {
            resultColor = AppColors.label
        } else if (fixture.teamScore! > fixture.opponentScore!) {
            resultColor = UIColor(named: "fixture-win")!
        } else if (fixture.teamScore! < fixture.opponentScore!) {
            resultColor = UIColor(named: "fixture-lose")!
        } else {
            resultColor = UIColor(named: "fixture-draw")!
        }
        
        // Set main label
        self.teamNameLabel.textColor = resultColor
        self.teamNameLabel.adjustsFontSizeToFitWidth = true
        self.teamNameLabel.text = fixture.displayOpponent
        
        // Set detail text
        self.scoreLabel.textColor = resultColor
        self.scoreLabel.adjustsFontSizeToFitWidth = true
        
        if (fixture.teamScore == nil || fixture.opponentScore == nil) {
            self.scoreLabel.text = fixture.kickoffTime
        } else {
            self.scoreLabel.text = fixture.score
        }
        
        TeamImageManager.shared.loadTeamImage(teamName: fixture.displayOpponent, view: self.logoImage)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
