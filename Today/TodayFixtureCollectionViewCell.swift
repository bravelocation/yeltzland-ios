//
//  TodayFixtureCollectionViewCell.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import UIKit

class TodayFixtureCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var scoreOrDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func updateData(_ entry: TimelineEntry) {
        
        self.opponentLabel.text = entry.opponentPlusHomeAway

        switch (entry.status) {
        case .result:
            self.gameTypeLabel.text = "RESULT"
            self.scoreOrDateLabel.text = entry.score
        case .inProgress:
            self.gameTypeLabel.text = "LATEST SCORE"
            self.scoreOrDateLabel.text = entry.score
        case .fixture:
            self.gameTypeLabel.text = "FIXTURE"
            self.scoreOrDateLabel.text = entry.kickoffTime
        }
        
        self.opponentLabel.adjustsFontSizeToFitWidth = true
        self.scoreOrDateLabel.adjustsFontSizeToFitWidth = true
        
        // Set colors
        self.gameTypeLabel.textColor = UIColor.white
        self.opponentLabel.textColor = UIColor.white
        self.scoreOrDateLabel.textColor = UIColor.white
        
        self.backgroundColor = UIColor.clear
        self.contentView.layer.backgroundColor = UIColor(named: "yeltz-blue")?.cgColor
        
        // Set cell border
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.borderWidth = 2.0
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.contentView.isUserInteractionEnabled = true
    }
}
