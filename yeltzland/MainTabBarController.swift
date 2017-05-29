//
//  MainTabBarController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class MainTabBarController: UITabBarController, UITabBarControllerDelegate, NSUserActivityDelegate {
    
    let defaults = UserDefaults.standard
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationWatcher()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.addChildViewControllers()
        self.selectedIndex = GameSettings.instance.lastSelectedTab;
        self.setupNotificationWatcher()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Removed notification handler for URL updates")
    }
    
    fileprivate func setupNotificationWatcher() {
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabBarController.setupHandoff), name: NSNotification.Name(rawValue: WebPageViewController.UrlNotification), object: nil)
        print("Setup notification handler for URL updates")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // Colors
        self.tabBar.barTintColor = AppColors.TabBarTintColor
        self.tabBar.tintColor = AppColors.TabBarTextColor
    }
    
    func addChildViewControllers() {
        // Forum
        let forumViewController = WebPageViewController()
        forumViewController.homeUrl = URL(string:"http://www.yeltz.co.uk/0/")
        forumViewController.pageTitle = "Yeltz Forum"
        let forumNavigationController = UINavigationController(rootViewController:forumViewController)
        
        let forumIcon = UITabBarItem(title: "Yeltz Forum", image: nil, selectedImage: nil)
        forumIcon.setFAIcon(icon: FAType.FAUsers, textColor:AppColors.TabBarUnselectedColor, selectedTextColor: AppColors.TabBarTextColor)
        forumNavigationController.tabBarItem = forumIcon

        // Official Site
        let officialViewController = WebPageViewController()
        officialViewController.homeUrl = URL(string:"https://www.ht-fc.co.uk")
        officialViewController.pageTitle = "Official Site"
        let officialNavigationController = UINavigationController(rootViewController:officialViewController)
        
        let officialIcon = UITabBarItem(title: "Official Site", image: nil, selectedImage: nil)
        officialIcon.setFAIcon(icon: FAType.FABlackTie, textColor:AppColors.TabBarUnselectedColor, selectedTextColor: AppColors.TabBarTextColor)
        officialNavigationController.tabBarItem = officialIcon
        
        // Yeltz TV
        let tvViewController = WebPageViewController()
        tvViewController.homeUrl = URL(string:"https://www.youtube.com/user/HalesowenTownFC")
        tvViewController.pageTitle = "Yeltz TV"
        let tvNavigationController = UINavigationController(rootViewController:tvViewController)
        
        let tvIcon = UITabBarItem(title: "Yeltz TV", image: nil, selectedImage: nil)
        tvIcon.setFAIcon(icon: FAType.FAYoutubePlay, textColor:AppColors.TabBarUnselectedColor, selectedTextColor: AppColors.TabBarTextColor)
        tvNavigationController.tabBarItem = tvIcon
        
        // Twitter
        let twitterViewController = TwitterUserTimelineViewController()
        twitterViewController.userScreenName = "halesowentownfc"
        let twitterNavigationController = UINavigationController(rootViewController:twitterViewController)
        
        let twitterIcon = UITabBarItem(title: "Twitter", image: nil, selectedImage: nil)
        twitterIcon.setFAIcon(icon: FAType.FATwitter, textColor:AppColors.TabBarUnselectedColor, selectedTextColor: AppColors.TabBarTextColor)
        twitterNavigationController.tabBarItem = twitterIcon
        
        // Other Links
        let otherViewController = OtherLinksTableViewController()
        let otherNavigationController = UINavigationController(rootViewController:otherViewController)
        
        let otherIcon = UITabBarItem(tabBarSystemItem: .more, tag: 4)
        otherNavigationController.tabBarItem = otherIcon

        // Add controllers
        let controllers = [forumNavigationController, officialNavigationController, tvNavigationController, twitterNavigationController, otherNavigationController]
        self.viewControllers = controllers
    }
    
    func latestUrl(_ url: URL) {
        
    }
    
    // Delegate methods
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // Find tab index of selected view controller, and store it as last selected
        var currentIndex = 0
        var selectedIndex = 0
        
        for currentController in self.viewControllers! {
            if (currentController == viewController) {
                selectedIndex = currentIndex
                break
            }
            currentIndex = currentIndex + 1
        }
        
        GameSettings.instance.lastSelectedTab = selectedIndex
        self.setupHandoff()

        return true;
    }
    
    func setupHandoff() {
        // Set activity for handoff
        let activity = NSUserActivity(activityType: "com.bravelocation.yeltzland.currenttab")
        activity.delegate = self
        activity.isEligibleForHandoff = true
        activity.needsSave = true
        
        self.userActivity = activity;
        self.userActivity?.becomeCurrent()
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        print("Restoring user activity in tab controller ...")
        
        if (activity.activityType == "com.bravelocation.yeltzland.currenttab") {
            if let info = activity.userInfo {
                if let tab = info["com.bravelocation.yeltzland.currenttab.key"] {
                    self.selectedIndex = tab as! Int
                    GameSettings.instance.lastSelectedTab = tab as! Int
                    print("Set tab to \(tab) due to userActivity call")
                    
                    if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                        if let selectedController = currentController.viewControllers[0] as? WebPageViewController {
                            if let currentUrl = info["com.bravelocation.yeltzland.currenttab.currenturl"] as? URL {
                                selectedController.loadPage(currentUrl)
                                print("Restoring URL to be \(currentUrl)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func userActivityWillSave(_ userActivity: NSUserActivity) {
        print("Saving user activity current tab to be \(self.selectedIndex)")

        userActivity.userInfo = [
            "com.bravelocation.yeltzland.currenttab.key": NSNumber(value: self.selectedIndex as Int),
        ]
        
        // Add current URL if a web view
        var currentUrl:URL? = nil
        
        if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
            if let selectedController = currentController.viewControllers[0] as? WebPageViewController {
                currentUrl = selectedController.webView.url
            }
        }
        
        if (currentUrl == nil) {
            userActivity.userInfo = [
                "com.bravelocation.yeltzland.currenttab.key": NSNumber(value: self.selectedIndex as Int)
            ]
        } else {
            userActivity.userInfo = [
                "com.bravelocation.yeltzland.currenttab.key": NSNumber(value: self.selectedIndex as Int),
                "com.bravelocation.yeltzland.currenttab.currenturl": currentUrl!
            ]
            
            print("Saving user activity current URL to be \(currentUrl!)")
        }
    }
}
