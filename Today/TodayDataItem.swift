//
//  TodayDataItem.swift
//  yeltzland
//
//  Created by John Pollard on 28/05/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class TodayDataItem: NSObject {
    var opponent: String = ""
    var scoreOrDate: String = ""
    var resultColor: UIColor = AppColors.label
    
    init(opponent: String, scoreOrDate: String, color: UIColor) {
        self.opponent = opponent
        self.scoreOrDate = scoreOrDate
        self.resultColor = color
    }
    
    init(opponent: String, scoreOrDate: String) {
        self.opponent = opponent
        self.scoreOrDate = scoreOrDate
        self.resultColor = AppColors.label
    }
}
