//
//  MainTabBarController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Intents

class MainTabBarController: UITabBarController, UITabBarControllerDelegate, NSUserActivityDelegate {
    
    let defaults = UserDefaults.standard
    let otherTabIndex = 4
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationWatcher()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.addChildViewControllers()
        self.selectedIndex = GameSettings.instance.lastSelectedTab
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
        self.tabBar.barTintColor = AppColors.systemBackground
        self.tabBar.tintColor = UIColor(named: "yeltz-blue")
    }
    
    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "1", modifierFlags: .command, action: #selector(MainTabBarController.keyboardSelectTab), discoverabilityTitle: "Yeltz Forum"),
            UIKeyCommand(input: "2", modifierFlags: .command, action: #selector(MainTabBarController.keyboardSelectTab), discoverabilityTitle: "Official Site"),
            UIKeyCommand(input: "3", modifierFlags: .command, action: #selector(MainTabBarController.keyboardSelectTab), discoverabilityTitle: "Yeltz TV"),
            UIKeyCommand(input: "4", modifierFlags: .command, action: #selector(MainTabBarController.keyboardSelectTab), discoverabilityTitle: "Twitter"),
            UIKeyCommand(input: "5", modifierFlags: .command, action: #selector(MainTabBarController.keyboardSelectTab), discoverabilityTitle: "More")
        ]
    }

    @objc func keyboardSelectTab(sender: UIKeyCommand) {
        if let selectedTab = sender.input {
            if let inputValue = Int(selectedTab) {
                self.selectedIndex = inputValue - 1
            }
        }
    }
    
    func addChildViewControllers() {
        // N.B. Must set font after setFAIcon as that messes up the text fonts
        
        // Forum
        let forumViewController = WebPageViewController()
        forumViewController.homeUrl = URL(string: "https://www.yeltz.co.uk")
        forumViewController.pageTitle = "Yeltz Forum"
        let forumNavigationController = UINavigationController(rootViewController: forumViewController)
        
        let forumIcon = UITabBarItem(title: "Yeltz Forum", image: UIImage(named: "forum"), selectedImage: nil)
        forumIcon.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: AppFonts.AppFontName, size: AppFonts.TabBarTextSize)!], for: UIControl.State())
        forumNavigationController.tabBarItem = forumIcon

        // Official Site
        let officialViewController = WebPageViewController()
        officialViewController.homeUrl = URL(string: "https://www.ht-fc.co.uk")
        officialViewController.pageTitle = "Official Site"
        let officialNavigationController = UINavigationController(rootViewController: officialViewController)
        
        let officialIcon = UITabBarItem(title: "Official Site", image: UIImage(named: "official"), selectedImage: nil)
        officialIcon.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: AppFonts.AppFontName, size: AppFonts.TabBarTextSize)!], for: UIControl.State())
        officialNavigationController.tabBarItem = officialIcon
        
        // Yeltz TV
        let tvViewController = WebPageViewController()
        tvViewController.homeUrl = URL(string: "https://www.youtube.com/user/HalesowenTownFC")
        tvViewController.pageTitle = "Yeltz TV"
        let tvNavigationController = UINavigationController(rootViewController: tvViewController)
        
        let tvIcon = UITabBarItem(title: "Yeltz TV", image: UIImage(named: "yeltztv"), selectedImage: nil)
        tvIcon.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: AppFonts.AppFontName, size: AppFonts.TabBarTextSize)!], for: UIControl.State())
        tvNavigationController.tabBarItem = tvIcon
        
        // Twitter
        let twitterViewController = TwitterUserTimelineViewController()
        twitterViewController.userScreenName = "halesowentownfc"
        let twitterNavigationController = UINavigationController(rootViewController: twitterViewController)
        
        let twitterIcon = UITabBarItem(title: "Twitter", image: UIImage(named: "twitter"), selectedImage: nil)
        twitterIcon.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: AppFonts.AppFontName, size: AppFonts.TabBarTextSize)!], for: UIControl.State())
        twitterNavigationController.tabBarItem = twitterIcon
        
        // Other Links
        var tableStyle: UITableView.Style = .grouped
        
        if #available(iOS 13.0, *) {
            tableStyle = .insetGrouped
        }
        
        let otherViewController = OtherLinksTableViewController(style: tableStyle)
        let otherNavigationController = UINavigationController(rootViewController: otherViewController)
        
        let otherIcon = UITabBarItem(tabBarSystemItem: .more, tag: self.otherTabIndex)
        otherIcon.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: AppFonts.AppFontName, size: AppFonts.TabBarTextSize)!], for: UIControl.State())
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
            currentIndex += 1
        }
        
        GameSettings.instance.lastSelectedTab = selectedIndex
        self.setupHandoff()

        return true
    }
    
    @objc func setupHandoff() {
        // Set activity for handoff
        let activity = NSUserActivity(activityType: "com.bravelocation.yeltzland.currenttab")
        activity.delegate = self
        
        // Eligible for handoff
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true

        // Set the title
        self.setActivitySearchTitleAndPhrase(activity)
        activity.needsSave = true

        self.userActivity = activity
        self.userActivity?.becomeCurrent()
    }
    
    private func setActivitySearchTitleAndPhrase(_ activity: NSUserActivity) {
        let currentIndex = GameSettings.instance.lastSelectedTab
        
        var activityTitle = "Open Yeltzland"
        var activityInvocationPhrase = "Open Yeltzland"
        
        switch currentIndex {
        case 0:
            activityTitle = "Read Yeltz Forum"
            activityInvocationPhrase = "Read the forum"
        case 1:
            activityTitle = "Read HTFC Official Site"
            activityInvocationPhrase = "Read the club website"
        case 2:
            activityTitle = "Watch Yeltz TV"
            activityInvocationPhrase = "Watch Yeltz TV"
        case 3:
            activityTitle = "Read HTFC Twitter Feed"
            activityInvocationPhrase = "Read the club twitter"
        default:
            break
        }
        
        activity.title = activityTitle
        if #available(iOS 12.0, *) {
            activity.suggestedInvocationPhrase = activityInvocationPhrase
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = String(format: "%@.com.bravelocation.yeltzland.currenttab.%d", Bundle.main.bundleIdentifier!, currentIndex)
        }
    }
    
    //swiftlint:disable:next cyclomatic_complexity
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
        } else if (activity.activityType == "com.bravelocation.yeltzland.fixtures") {
            print("Detected fixture list activity ...")
            // Set selected tab as More tab
            self.selectedIndex = self.otherTabIndex
            GameSettings.instance.lastSelectedTab = self.otherTabIndex
            
            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                    selectedController.openFixtures()
                }
            }
        } else if (activity.activityType == "com.bravelocation.yeltzland.latestscore") {
            print("Detected Latest score activity ...")
            // Set selected tab as More tab
            self.selectedIndex = self.otherTabIndex
            GameSettings.instance.lastSelectedTab = self.otherTabIndex
            
            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                    selectedController.openLatestScore()
                }
            }
        }
    }
    
    func userActivityWillSave(_ userActivity: NSUserActivity) {
        print("Saving user activity \(String(describing: userActivity.title)) index to be \(GameSettings.instance.lastSelectedTab)")

        userActivity.userInfo = [
            "com.bravelocation.yeltzland.currenttab.key": NSNumber(value: GameSettings.instance.lastSelectedTab as Int)
        ]
        
        // Add current URL if a web view
        
        DispatchQueue.main.async {
            var currentUrl: URL? = nil

            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                if let selectedController = currentController.viewControllers[0] as? WebPageViewController {
                    DispatchQueue.main.async(execute: { () -> Void in
                        currentUrl = selectedController.webView.url
                    })
                }
            }
            
            if (currentUrl != nil) {
                userActivity.userInfo = [
                    "com.bravelocation.yeltzland.currenttab.key": NSNumber(value: GameSettings.instance.lastSelectedTab as Int),
                    "com.bravelocation.yeltzland.currenttab.currenturl": currentUrl!
                ]
                
                print("Saving user activity current URL to be \(currentUrl!)")
            }
        }
    }
}
