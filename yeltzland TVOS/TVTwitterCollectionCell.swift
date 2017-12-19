//
//  TVTwitterCollectionCell.swift
//  yeltzlandTVOS
//
//  Created by John Pollard on 19/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class TVTwitterCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var tweetLabel: VerticallyAlignedLabel!
    
    func loadData(tweet:String) {
        self.tweetLabel.text = tweet
        
        // Setup the colors
        self.layer.backgroundColor = AppColors.TVTwitterBackground.cgColor
        self.tweetLabel.textColor = AppColors.TVTwitterText
    }
}
