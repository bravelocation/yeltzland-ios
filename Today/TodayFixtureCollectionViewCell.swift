//
//  TodayFixtureCollectionViewCell.swift
//  yeltzland
//
//  Created by John Pollard on 18/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import UIKit

class TodayFixtureCollectionViewCell: UICollectionViewCell {

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
            self.scoreOrDateLabel.text = "\(entry.teamScore ?? 0)-\(entry.opponentScore ?? 0)"
        case .inProgress:
            self.scoreOrDateLabel.text = "\(entry.teamScore ?? 0)-\(entry.opponentScore ?? 0)*"
        case .fixture:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE dd MMM"
            
            self.scoreOrDateLabel.text = dateFormatter.string(from: entry.date)
        }
        
        self.opponentLabel.adjustsFontSizeToFitWidth = true
        self.scoreOrDateLabel.adjustsFontSizeToFitWidth = true
        
        // Set colors
        let resultColor = self.getFixtureDisplayColor(entry)
        self.opponentLabel.textColor = resultColor
        self.scoreOrDateLabel.textColor = resultColor
        
        self.backgroundColor = UIColor.blue
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
