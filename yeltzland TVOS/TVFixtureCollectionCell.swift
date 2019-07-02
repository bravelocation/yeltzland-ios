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
    
    func loadData(dataItem: TVFixtureData) {
        self.opponentLabel.text = dataItem.opponent
        self.scoreLabel.text = dataItem.score
        self.dateLabel.text = dataItem.matchDate
        
        if (dataItem.atHome) {
            self.homeAwayLabel.text = "at home to"
        } else {
            self.homeAwayLabel.text = "away at"
        }
        
        // Setup the colors
        self.layer.backgroundColor = UIColor.black.cgColor
        
        TeamImageManager.instance.loadTeamImage(teamName: dataItem.opponent, view: self.calendarImage)
        //self.calendarImage.image = self.calendarImage.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        if (dataItem.inProgress || dataItem.score.count == 0) {
            self.contentView.backgroundColor = UIColor(named: "dark-blue")
            self.opponentLabel.textColor = UIColor.white
            self.dateLabel.textColor = UIColor.white
            self.homeAwayLabel.textColor = UIColor.white
            self.calendarImage.tintColor = UIColor.white
        } else {
            self.contentView.backgroundColor = UIColor(named: "dark-blue")
            self.opponentLabel.textColor = UIColor.white
            self.dateLabel.textColor = UIColor.white
            self.homeAwayLabel.textColor = UIColor.white
            self.scoreLabel.textColor = dataItem.scoreColor
            self.calendarImage.tintColor = UIColor.white
        }
        
        self.contentView.layer.borderWidth = 0.0
    }
}
