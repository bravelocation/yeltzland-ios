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
    
    func loadData(dataItem: TimelineFixture) {
        self.opponentLabel.text = dataItem.opponentPlusHomeAway
        self.scoreLabel.text = dataItem.score
        self.dateLabel.text = dataItem.kickoffTime
        
        if (dataItem.home) {
            self.homeAwayLabel.text = "at home to"
        } else {
            self.homeAwayLabel.text = "away at"
        }
        
        // Setup the colors
        self.layer.backgroundColor = UIColor.black.cgColor
        
        TeamImageManager.shared.loadTeamImage(teamName: dataItem.opponent, view: self.calendarImage)
        //self.calendarImage.image = self.calendarImage.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        self.contentView.backgroundColor = UIColor(named: "dark-blue")
        self.opponentLabel.textColor = UIColor.white
        self.dateLabel.textColor = UIColor.white
        self.homeAwayLabel.textColor = UIColor.white
        self.calendarImage.tintColor = UIColor.white
        
        if (dataItem.status == .inProgress || dataItem.status == .result) {
            var resultColor: UIColor = UIColor.white
            
            if (dataItem.teamScore! > dataItem.opponentScore!) {
                resultColor = UIColor(named: "tv-fixture-win")!
            } else if (dataItem.teamScore! < dataItem.opponentScore!) {
                resultColor = UIColor(named: "tv-fixture-lose")!
            } else {
                resultColor = UIColor(named: "light-blue")!
            }
            
            self.scoreLabel.textColor = resultColor
        }
        
        self.contentView.layer.borderWidth = 0.0
    }
}
