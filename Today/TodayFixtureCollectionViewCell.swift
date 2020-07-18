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
        
        self.opponentLabel.text = entry.opponent
        
        switch (entry.status) {
        case .result:
            self.gameTypeLabel.text = "RESULT"
            self.scoreOrDateLabel.text = "\(entry.teamScore ?? 0)-\(entry.opponentScore ?? 0)"
        case .inProgress:
            self.gameTypeLabel.text = "LATEST SCORE"
            self.scoreOrDateLabel.text = "\(entry.teamScore ?? 0)-\(entry.opponentScore ?? 0)*"
        case .fixture:
            self.gameTypeLabel.text = "FIXTURE"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE dd MMM"
            
            self.scoreOrDateLabel.text = dateFormatter.string(from: entry.date)
        }
        
        self.opponentLabel.adjustsFontSizeToFitWidth = true
        self.scoreOrDateLabel.adjustsFontSizeToFitWidth = true
        
        // Set colors
        self.gameTypeLabel.textColor = UIColor.white
        self.opponentLabel.textColor = UIColor.white
        self.scoreOrDateLabel.textColor = UIColor.white
        
        self.contentView.layer.backgroundColor = UIColor(named: "yeltz-blue")?.cgColor
        
        // Set cell border
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.borderWidth = 2.0
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.contentView.isUserInteractionEnabled = true
    }
    
    private func getFixtureDisplayColor(_ fixture: TimelineEntry?) -> UIColor {
        var resultColor = AppColors.label
        
        guard let fixture = fixture else {
            return resultColor
        }
        
        let teamScore = fixture.teamScore
        let opponentScore  = fixture.opponentScore
        
        if (teamScore != nil && opponentScore != nil) {
            if (teamScore! > opponentScore!) {
                resultColor = UIColor(named: "fixture-win")!
            } else if (teamScore! < opponentScore!) {
                resultColor = UIColor(named: "fixture-lose")!
            } else {
                resultColor = UIColor(named: "fixture-draw")!
            }
        }
        
        return resultColor
    }

}
