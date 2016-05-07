//
//  AppDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Nav bar colors
        UINavigationBar.appearance().barTintColor = AppColors.NavBarColor;
        
        let bodyDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleHeadline);
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: AppColors.NavBarTextColor,
            NSFontAttributeName: UIFont(name: "AmericanTypewriter", size:bodyDescriptor.pointSize)!
        ]
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        Fabric.with([Crashlytics.self, Twitter.self])
        
        // Initial web page
        let initialTabViewController = MainTabBarController()
        self.window?.rootViewController = initialTabViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

