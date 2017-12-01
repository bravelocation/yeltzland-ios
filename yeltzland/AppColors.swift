//
//  AppColors.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit

let YeltzBlueColor = UIColor(red: 6.0/255.0, green: 55.0/255.0, blue: 150.0/255.0, alpha: 1.0)
let LightBlueColor = UIColor(red: 202.0/255.0, green: 220.0/255.0, blue: 235.0/255.0, alpha: 1.0)
let LightBlueTransparentColor = UIColor(red: 202.0/255.0, green: 220.0/255.0, blue: 235.0/255.0, alpha: 0.8)
let DarkBlueColor = UIColor(red: 6.0/255.0, green: 29.0/255.0, blue: 73.0/255.0, alpha: 1.0)
let FacebookBlueColor = UIColor(red: 71.0/255.0, green: 96.0/255.0, blue: 159.0/255.0, alpha: 1.0)
let StourbridgeRedColor = UIColor(red: 158.0/255.0, green: 0.0/255.0, blue: 26.0/255.0, alpha: 1.0)
let EvostickRedColor = UIColor(red: 252.0/255.0, green: 0.0/255.0, blue: 6.0/255.0, alpha: 1.0)
let BraveLocationRedColor = UIColor(red: 170.0/255.0, green: 60.0/255.0, blue: 79.0/255.0, alpha: 1.0)
let TwitterColor = UIColor(red: 66.0/255.0, green: 148.0/255.0, blue: 254.0/255.0, alpha: 1.0)

let headlineDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.headline)
let bodyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
let footnoteDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.footnote)

let ios10AndAbove:Bool = ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0))

class AppColors {
    static var AppFontName = "AmericanTypewriter"
    static var isIos10AndAbove = ios10AndAbove
    
    static var NavBarTextSize = headlineDescriptor.pointSize
    static var NavBarColor: UIColor = YeltzBlueColor
    static var NavBarTextColor: UIColor = UIColor.white
    static var NavBarTintColor: UIColor = UIColor.white
    
    static var ProgressBar: UIColor = YeltzBlueColor
    static var WebBackground: UIColor = UIColor.white
    static var WebErrorBackground: UIColor = YeltzBlueColor

    static var TabBarTextSize = footnoteDescriptor.pointSize - 2.0
    static var TabBarTextColor: UIColor = YeltzBlueColor
    static var TabBarTintColor: UIColor = UIColor.white
    static var TabBarUnselectedColor: UIColor = UIColor.gray
    
    static var TwitterBackground: UIColor = UIColor.white
    static var TwitterSeparator: UIColor = UIColor.white
    
    static var OtherBackground: UIColor = UIColor.white
    static var OtherSectionBackground: UIColor = LightBlueColor
    static var OtherSectionText: UIColor = YeltzBlueColor
    static var OtherSeparator: UIColor = UIColor.white
    static var OtherSectionTextSize = bodyDescriptor.pointSize
    static var OtherTextSize = bodyDescriptor.pointSize
    static var OtherDetailTextSize = footnoteDescriptor.pointSize
    static var OtherTextColor = UIColor.black
    static var OtherDetailColor = UIColor.gray
    
    static var FixtureTeamSize = bodyDescriptor.pointSize
    static var FixtureScoreOrDateTextSize = footnoteDescriptor.pointSize
    
    static var Fixtures: UIColor = YeltzBlueColor
    static var Evostick: UIColor = EvostickRedColor
    static var Fantasy: UIColor = YeltzBlueColor
    static var Stour: UIColor = StourbridgeRedColor
    static var BraveLocation: UIColor = BraveLocationRedColor
    static var Facebook: UIColor = FacebookBlueColor
    static var Archive: UIColor = YeltzBlueColor
    static var TwitterIcon: UIColor = TwitterColor
    
    static var SpinnerColor = YeltzBlueColor
    
    static var ToastBackgroundColor = YeltzBlueColor
    static var ToastTextColor = UIColor.white
    static var ToastTextSize = headlineDescriptor.pointSize
    
    static var FixtureWin = UIColor(red: 0.0/255.0, green: 63.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static var FixtureDraw = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    static var FixtureLose = UIColor(red: 63.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static var FixtureNone = UIColor.black
    
    static var TodayBackground = ios10AndAbove ? LightBlueColor : UIColor.clear
    static var TodaySeparator = UIColor.red
    static var TodaySectionText = ios10AndAbove ? YeltzBlueColor : LightBlueColor
    static var TodayText = ios10AndAbove ? UIColor.black : UIColor.white
    static var TodayTextSize = bodyDescriptor.pointSize
    static var TodayFootnoteSize = footnoteDescriptor.pointSize
    
    static var WatchMonthColor:UIColor = LightBlueColor
    static var WatchTextColor:UIColor = UIColor.white
    static var WatchFixtureWin = UIColor(red: 127.0/255.0, green: 255.0/255.0, blue: 127.0/255.0, alpha: 1.0)
    static var WatchFixtureDraw = UIColor.white
    static var WatchFixtureLose = UIColor(red: 255.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
    static var WatchComplicationColor:UIColor = LightBlueColor
    
    static var SafariControl:UIColor = YeltzBlueColor
}

    
