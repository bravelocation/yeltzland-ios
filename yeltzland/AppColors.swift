//
//  AppColors.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit

let yeltzBlueColor = UIColor(red: 6.0/255.0, green: 55.0/255.0, blue: 150.0/255.0, alpha: 1.0)
let lightBlueColor = UIColor(red: 202.0/255.0, green: 220.0/255.0, blue: 235.0/255.0, alpha: 1.0)
let lightBlueTransparentColor = UIColor(red: 202.0/255.0, green: 220.0/255.0, blue: 235.0/255.0, alpha: 0.8)
let darkBlueColor = UIColor(red: 6.0/255.0, green: 29.0/255.0, blue: 73.0/255.0, alpha: 1.0)
let facebookBlueColor = UIColor(red: 71.0/255.0, green: 96.0/255.0, blue: 159.0/255.0, alpha: 1.0)
let stourbridgeRedColor = UIColor(red: 158.0/255.0, green: 0.0/255.0, blue: 26.0/255.0, alpha: 1.0)
let evostickRedColor = UIColor(red: 252.0/255.0, green: 0.0/255.0, blue: 6.0/255.0, alpha: 1.0)
let braveLocationRedColor = UIColor(red: 170.0/255.0, green: 60.0/255.0, blue: 79.0/255.0, alpha: 1.0)
let twitterColor = UIColor(red: 66.0/255.0, green: 148.0/255.0, blue: 254.0/255.0, alpha: 1.0)

let headlineDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.headline)
let bodyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body)
let footnoteDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.footnote)

let ios10AndAbove:Bool = ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0))

class AppColors {
    static var AppFontName = "AmericanTypewriter"
    static var isIos10AndAbove = ios10AndAbove
    
    static var NavBarTextSize = headlineDescriptor.pointSize
    static var NavBarColor: UIColor = yeltzBlueColor
    static var NavBarTextColor: UIColor = UIColor.white
    static var NavBarTintColor: UIColor = UIColor.white
    
    static var ProgressBar: UIColor = yeltzBlueColor
    static var WebBackground: UIColor = UIColor.white
    static var WebErrorBackground: UIColor = yeltzBlueColor

    static var TabBarTextSize = footnoteDescriptor.pointSize - 2.0
    static var TabBarTextColor: UIColor = yeltzBlueColor
    static var TabBarTintColor: UIColor = UIColor.white
    static var TabBarUnselectedColor: UIColor = UIColor.gray
    
    static var TwitterBackground: UIColor = UIColor.white
    static var TwitterSeparator: UIColor = UIColor.white
    
    static var OtherBackground: UIColor = UIColor.white
    static var OtherSectionBackground: UIColor = lightBlueColor
    static var OtherSectionText: UIColor = yeltzBlueColor
    static var OtherSeparator: UIColor = UIColor.white
    static var OtherSectionTextSize = bodyDescriptor.pointSize
    static var OtherTextSize = bodyDescriptor.pointSize
    static var OtherDetailTextSize = footnoteDescriptor.pointSize
    static var OtherTextColor = UIColor.black
    static var OtherDetailColor = UIColor.gray
    
    static var FixtureTeamSize = bodyDescriptor.pointSize
    static var FixtureScoreOrDateTextSize = footnoteDescriptor.pointSize
    
    static var Fixtures: UIColor = yeltzBlueColor
    static var ClubShop: UIColor = yeltzBlueColor
    static var Evostick: UIColor = evostickRedColor
    static var Fantasy: UIColor = yeltzBlueColor
    static var Stour: UIColor = stourbridgeRedColor
    static var BraveLocation: UIColor = braveLocationRedColor
    static var Facebook: UIColor = facebookBlueColor
    static var Archive: UIColor = yeltzBlueColor
    static var TwitterIcon: UIColor = twitterColor
    
    static var SpinnerColor = yeltzBlueColor
    
    static var ToastBackgroundColor = yeltzBlueColor
    static var ToastTextColor = UIColor.white
    static var ToastTextSize = headlineDescriptor.pointSize
    
    static var FixtureWin = UIColor(red: 0.0/255.0, green: 63.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static var FixtureDraw = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    static var FixtureLose = UIColor(red: 63.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static var FixtureNone = UIColor.black
    
    static var TodayBackground = UIColor.clear
    static var TodayHeaderText = UIColor.black
    static var TodayText = UIColor.black
    static var TodayTextSize = bodyDescriptor.pointSize
    static var TodayFootnoteSize = footnoteDescriptor.pointSize
    
    static var WatchMonthColor:UIColor = lightBlueColor
    static var WatchTextColor:UIColor = UIColor.white
    static var WatchFixtureWin = UIColor(red: 127.0/255.0, green: 255.0/255.0, blue: 127.0/255.0, alpha: 1.0)
    static var WatchFixtureDraw = UIColor.white
    static var WatchFixtureLose = UIColor(red: 255.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
    static var WatchComplicationColor:UIColor = lightBlueColor
    static var WatchRingColor:UIColor = yeltzBlueColor

    static var SafariControl:UIColor = yeltzBlueColor
    
    static var TVBackground = UIColor.black
    static var TVTitleText: UIColor = lightBlueColor
    static var TVSelectedBorder: UIColor = UIColor.white
    
    static var TVFixtureBackground: UIColor = yeltzBlueColor
    static var TVFixtureText: UIColor = UIColor.white
    static var TVResultBackground: UIColor = darkBlueColor
    static var TVResultText: UIColor = UIColor.white
    static var TVMatchShadow: UIColor = UIColor.white

    static var TVFixtureWin = UIColor(red: 63.0/255.0, green: 255.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    static var TVFixtureDraw = lightBlueColor
    static var TVFixtureLose = UIColor(red: 255.0/255.0, green: 63.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    
    static var TVTwitterBackground: UIColor = darkBlueColor
    static var TVTwitterText: UIColor = UIColor.white

    static var SiriIntentText: UIColor = UIColor.black
    static var SiriIntentTextSize = bodyDescriptor.pointSize
}

    
