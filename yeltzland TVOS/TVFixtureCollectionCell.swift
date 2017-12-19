//
//  TVFixtureCollectionCell.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 18/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class TVFixtureCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var homeAwayLabel: UILabel!
    @IBOutlet weak var calendarImage: UIImageView!
    
    func loadData(dataItem:TVFixtureData) {
        self.opponentLabel.text = dataItem.opponent
        self.scoreLabel.text = dataItem.score
        self.dateLabel.text = dataItem.matchDate
        
        if (dataItem.atHome) {
            self.homeAwayLabel.text = "at home to"
        } else {
            self.homeAwayLabel.text = "away at"
        }
        
        // Setup the colors
        self.layer.backgroundColor = AppColors.TVBackground.cgColor
        
        self.calendarImage.image = self.calendarImage.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        if (dataItem.score.count == 0) {
            self.contentView.backgroundColor = AppColors.TVFixtureBackground
            self.opponentLabel.textColor = AppColors.TVFixtureText
            self.dateLabel.textColor = AppColors.TVFixtureText
            self.homeAwayLabel.textColor = AppColors.TVFixtureText
            self.contentView.layer.borderColor = AppColors.TVFixtureBorderColor.cgColor
            self.calendarImage.tintColor = AppColors.TVFixtureText
        } else {
            self.contentView.backgroundColor = AppColors.TVResultBackground
            self.opponentLabel.textColor = AppColors.TVResultText
            self.dateLabel.textColor = AppColors.TVResultText
            self.homeAwayLabel.textColor = AppColors.TVResultText
            self.scoreLabel.textColor = dataItem.scoreColor
            self.contentView.layer.borderColor = AppColors.TVResultBorderColor.cgColor
            self.calendarImage.tintColor = AppColors.TVResultText
        }
        
        self.contentView.layer.borderWidth = 1.0
    }
}
