//
//  TVFixtureData.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import Foundation
import UIKit

class TVFixtureData: NSObject {
    var opponent: String = ""
    var score: String = ""
    var matchDate: String = ""
    var inProgress: Bool = false
    var atHome: Bool = false
    var scoreColor: UIColor = AppColors.TVResultText

    init(opponent: String, matchDate: String, score: String, inProgress: Bool, atHome: Bool, scoreColor: UIColor = AppColors.TVResultText) {
        self.opponent = opponent
        self.matchDate = matchDate
        self.score = score
        self.inProgress = inProgress
        self.atHome = atHome
        self.scoreColor = scoreColor
    }
}
