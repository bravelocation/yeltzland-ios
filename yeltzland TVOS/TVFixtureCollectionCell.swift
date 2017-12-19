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

    func loadData(dataItem:TVDataItem) {
        self.opponentLabel.text = dataItem.opponent
        self.scoreLabel.text = dataItem.score
        self.dateLabel.text = dataItem.matchDate
        
        // Setup the colors
        self.layer.backgroundColor = AppColors.TVBackground.cgColor
        
        if (dataItem.score.count == 0) {
            self.contentView.backgroundColor = AppColors.TVFixtureBackground
        } else {
            self.contentView.backgroundColor = AppColors.TVResultBackground
        }
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = AppColors.TVBorderColor.cgColor
        self.contentView.layer.cornerRadius = 16.0
        
        self.contentView.layer.shadowColor = AppColors.TVMatchShadow.cgColor
        self.contentView.layer.shadowRadius = 4.0
        self.contentView.layer.shadowOpacity = 0.9
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)

        self.opponentLabel.textColor = AppColors.TVMatchText
        self.dateLabel.textColor = AppColors.TVMatchText
        self.scoreLabel.textColor = dataItem.scoreColor
    }
}
