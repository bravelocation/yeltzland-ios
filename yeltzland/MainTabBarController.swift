//
//  MainTabBarController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Intents

#if canImport(SwiftUI)
import SwiftUI
#endif

/// Main tab bar controller
class MainTabBarController: UITabBarController, UITabBarControllerDelegate, NSUserActivityDelegate {
    
    // MARK: Private variables
    private let defaults = UserDefaults.standard
    private let otherTabIndex = 4
    
    // MARK: - Initialisation
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationWatcher()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.addChildViewControllers()
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

    // MARK: Event handlers
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // Colors
        self.tabBar.barTintColor = AppColors.systemBackground
        self.tabBar.tintColor = UIColor(named: "blue-tint")
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
    
    // MARK: - UITabBarControllerDelegate methods
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        GameSettings.shared.lastSelectedTab = selectedIndex
        self.setupHandoff()
    }
    
    // MARK: - NSUserActivityDelegate functions
    func userActivityWillSave(_ userActivity: NSUserActivity) {

        DispatchQueue.main.async {
            var currentUrl: URL? = nil
            
            userActivity.userInfo = [
                "com.bravelocation.yeltzland.currenttab.key": NSNumber(value: self.selectedIndex)
            ]
            
            // Add current URL if a web view
            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                if let selectedController = currentController.viewControllers[0] as? WebPageViewController {
                    currentUrl = selectedController.webView.url
                }
            }
            
            if (currentUrl != nil) {
                userActivity.userInfo = [
                    "com.bravelocation.yeltzland.currenttab.key": NSNumber(value: self.selectedIndex),
                    "com.bravelocation.yeltzland.currenttab.currenturl": currentUrl!
                ]
                
                print("Saving user activity current URL to be \(currentUrl!)")
            }
            
            if #available(iOS 13.0, *) {
                self.view.window?.windowScene?.userActivity = userActivity
            }
        }
    }
    
    // MARK: - UIResponder function
    
    /// Description Restores the tab state based on the juser activity
    /// - Parameter activity: Activity state to restore
    //swiftlint:disable:next cyclomatic_complexity
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        print("Restoring user activity in tab controller ...")
        
        if (activity.activityType == "com.bravelocation.yeltzland.currenttab") {
            if let info = activity.userInfo {
                if let tab = info["com.bravelocation.yeltzland.currenttab.key"] {
                    self.selectedIndex = tab as! Int
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
            
            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                    selectedController.openFixtures()
                }
            }
        } else if (activity.activityType == "com.bravelocation.yeltzland.latestscore") {
            print("Detected Latest score activity ...")
            // Set selected tab as More tab
            self.selectedIndex = self.otherTabIndex
            
            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                    selectedController.openLatestScore()
                }
            }
        }
    }
    
    // MARK: - Private functions
    
    /// Sets up the child controllers for the tabs
    func addChildViewControllers() {
        // Forum
        let forumViewController = WebPageViewController()
        forumViewController.homeUrl = URL(string: "https://www.yeltz.co.uk")
        forumViewController.pageTitle = "Yeltz Forum"
        let forumNavigationController = UINavigationController(rootViewController: forumViewController)
        
        let forumIcon = UITabBarItem(title: "Yeltz Forum", image: UIImage(named: "forum"), selectedImage: nil)
        forumNavigationController.tabBarItem = forumIcon
        
        // Official Site
        let officialViewController = WebPageViewController()
        officialViewController.homeUrl = URL(string: "https://www.ht-fc.co.uk")
        officialViewController.pageTitle = "Official Site"
        let officialNavigationController = UINavigationController(rootViewController: officialViewController)
        
        let officialIcon = UITabBarItem(title: "Official Site", image: UIImage(named: "official"), selectedImage: nil)
        officialNavigationController.tabBarItem = officialIcon
        
        // Yeltz TV
        let tvViewController = WebPageViewController()
        tvViewController.homeUrl = URL(string: "https://www.youtube.com/channel/UCGZMWQtMsC4Tep6uLm5V0nQ")
        tvViewController.pageTitle = "Yeltz TV"
        let tvNavigationController = UINavigationController(rootViewController: tvViewController)
        
        let tvIcon = UITabBarItem(title: "Yeltz TV", image: UIImage(named: "yeltztv"), selectedImage: nil)
        tvNavigationController.tabBarItem = tvIcon
        
        // Twitter
        let twitterAccountName = "halesowentownfc"
        let twitterIcon = UITabBarItem(title: "@\(twitterAccountName)", image: UIImage(named: "twitter"), selectedImage: nil)
        var twitterNavigationController: UINavigationController?
        
        if #available(iOS 13.0, *) {
            let twitterConsumerKey = SettingsManager.shared.getSetting("TwitterConsumerKey") as! String
            let twitterConsumerSecret = SettingsManager.shared.getSetting("TwitterConsumerSecret") as! String
            
            let twitterDataProvider = TwitterDataProvider(
                twitterConsumerKey: twitterConsumerKey,
                twitterConsumerSecret: twitterConsumerSecret,
                tweetCount: 20,
                accountName: twitterAccountName
            )
            let tweetData = TweetData(dataProvider: twitterDataProvider, accountName: twitterAccountName)
            let twitterViewController = UIHostingController(rootView: TwitterTimelineView().environmentObject(tweetData))
            
            twitterNavigationController = UINavigationController(rootViewController: twitterViewController)
            twitterNavigationController?.tabBarItem = twitterIcon
        } else {
            let twitterViewController = WebPageViewController()
            twitterViewController.homeUrl = URL(string: "https://mobile.twitter.com/\(twitterAccountName)")
            twitterViewController.pageTitle = "Twitter"
            
            twitterNavigationController = UINavigationController(rootViewController: twitterViewController)
            twitterNavigationController?.tabBarItem = twitterIcon
        }
        
        // Other Links
        var tableStyle: UITableView.Style = .grouped
        
        if #available(iOS 13.0, *) {
            tableStyle = .insetGrouped
        }
        
        let otherViewController = OtherLinksTableViewController(style: tableStyle)
        let otherNavigationController = UINavigationController(rootViewController: otherViewController)
        
        let otherIcon = UITabBarItem(tabBarSystemItem: .more, tag: self.otherTabIndex)
        otherNavigationController.tabBarItem = otherIcon
        
        // Add controllers
        let controllers = [forumNavigationController, officialNavigationController, tvNavigationController, twitterNavigationController!, otherNavigationController]
        self.viewControllers = controllers
    }
    
    /// Called when we need to save user activity
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
    
    /// Sets the title and invocation phrase for the user activity
    /// - Parameter activity: User activity to configure
    private func setActivitySearchTitleAndPhrase(_ activity: NSUserActivity) {
        var activityTitle = "Open Yeltzland"
        var activityInvocationPhrase = "Open Yeltzland"
        
        switch self.selectedIndex {
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
            activity.persistentIdentifier = String(format: "%@.com.bravelocation.yeltzland.currenttab.%d", Bundle.main.bundleIdentifier!, self.selectedIndex)
        }
    }
}
