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
    var scoreOrDate:String = ""
    var resultColor:UIColor = AppColors.TVText;
    
    init(opponent:String, scoreOrDate:String, color: UIColor) {
        self.opponent = opponent
        self.scoreOrDate = scoreOrDate
        self.resultColor = color
    }
    
    init(opponent:String, scoreOrDate:String) {
        self.opponent = opponent
        self.scoreOrDate = scoreOrDate
        self.resultColor = AppColors.TVText
    }
}
