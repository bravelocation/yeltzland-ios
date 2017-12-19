//
//  TVDataItem.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import Foundation
import UIKit

class TVDataItem: NSObject {
    var opponent:String = ""
    var score:String = ""
    var matchDate:String = ""
    var inProgress:Bool = false
    var scoreColor:UIColor = AppColors.TVMatchText

    init(opponent:String, matchDate:String, score:String, inProgress:Bool, scoreColor:UIColor = AppColors.TVMatchText) {
        self.opponent = opponent
        self.matchDate = matchDate
        self.score = score
        self.inProgress = inProgress
        self.scoreColor = scoreColor
    }
}
