//
//  AppColors.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit

let headlineDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.headline)
let bodyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body)
let footnoteDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.footnote)

class AppFonts {
    static var AppFontName = "AmericanTypewriter"
    
    static var NavBarTextSize = headlineDescriptor.pointSize
    static var TabBarTextSize = footnoteDescriptor.pointSize - 2.0
    
    static var OtherSectionTextSize = bodyDescriptor.pointSize
    static var OtherTextSize = bodyDescriptor.pointSize
    static var OtherDetailTextSize = footnoteDescriptor.pointSize
    
    static var FixtureTeamSize = bodyDescriptor.pointSize
    static var FixtureScoreOrDateTextSize = footnoteDescriptor.pointSize
    
    static var ToastTextSize = headlineDescriptor.pointSize
    
    static var TodayTextSize = bodyDescriptor.pointSize
    static var TodayFootnoteSize = footnoteDescriptor.pointSize

    static var SiriIntentTextSize = bodyDescriptor.pointSize
}
