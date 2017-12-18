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
    }
}
