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
import Combine
#endif

/// Main tab bar controller
class MainTabBarController: UITabBarController, UITabBarControllerDelegate, NSUserActivityDelegate {
    
    // MARK: Private variables
    private let defaults = UserDefaults.standard
    private let otherTabIndex = 4
    private var navigationData: NavigationManager = NavigationManager()
    
    @available(iOS 13.0, *)
    private lazy var menuSubscriber: AnyCancellable? = nil
    
    // MARK: - Initialisation
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationWatcher()
        self.setupMenuCommandHandler()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.addChildViewControllers()
        self.setupNotificationWatcher()
        self.setupMenuCommandHandler()
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
        return self.navigationData.keyCommands(selector: #selector(MainTabBarController.keyboardSelectTab), useMore: true)
    }

    @objc func keyboardSelectTab(sender: UIKeyCommand) {
        if let keyInput = sender.input {
            if let inputValue = Int(keyInput) {
                self.selectedIndex = inputValue - 1
            } else {
                switch keyInput {
                case "F": self.goToFixturesView()
                case "L": self.goToLatestScore()
                case "G": self.goToLocations()
                case "T": self.goToLeagueTable()
                default: break
                }
            }
        }
    }

    // MARK: - Menu options
    func setupMenuCommandHandler() {
        if #available(iOS 13.0, *) {
            self.menuSubscriber = NotificationCenter.default.publisher(for: .navigationCommand)
                .receive(on: RunLoop.main)
                .sink(receiveValue: { notification in
                    if let command = notification.object as? UIKeyCommand {
                        self.keyboardSelectTab(sender: command)
                    }
                })
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
            self.goToFixturesView()
        } else if (activity.activityType == "com.bravelocation.yeltzland.latestscore") {
            print("Detected Latest score activity ...")
            self.goToLatestScore()
        }
    }
    
    // MARK: - Private functions
    
    func goToFixturesView() {
        // Set selected tab as More tab
        self.selectedIndex = self.otherTabIndex
        
        if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
            currentController.popToRootViewController(animated: false)
            if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                selectedController.openFixtures()
            }
        }
    }
    
    func goToLatestScore() {
        // Set selected tab as More tab
        self.selectedIndex = self.otherTabIndex
        
        if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
            currentController.popToRootViewController(animated: false)
            if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                selectedController.openLatestScore()
            }
        }
    }
    
    func goToLocations() {
        // Set selected tab as More tab
        self.selectedIndex = self.otherTabIndex
        
        if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
            currentController.popToRootViewController(animated: false)
            if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                selectedController.openLocations()
            }
        }
    }

    func goToLeagueTable() {
        // Set selected tab as More tab
        self.selectedIndex = self.otherTabIndex
        
        if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
            currentController.popToRootViewController(animated: false)
            if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                selectedController.openLeagueTable()
            }
        }
    }
    
    /// Sets up the child controllers for the tabs
    func addChildViewControllers() {
        var controllers: [UINavigationController] = []
        
        for mainNavElement in self.navigationData.mainSection.elements {
            switch mainNavElement.type {
            case .controller(let viewController):
                let navController = UINavigationController(rootViewController: viewController)
                
                let tabIcon = UITabBarItem(title: mainNavElement.title, image: UIImage(named: mainNavElement.imageName!), selectedImage: nil)
                navController.tabBarItem = tabIcon
                
                controllers.append(navController)
            case .link(let url):
                let webViewController = WebPageViewController()
                webViewController.homeUrl = url
                webViewController.pageTitle = mainNavElement.title
                let webNavigationController = UINavigationController(rootViewController: webViewController)
                
                let tabIcon = UITabBarItem(title: mainNavElement.title, image: UIImage(named: mainNavElement.imageName!), selectedImage: nil)
                webNavigationController.tabBarItem = tabIcon
                
                controllers.append(webNavigationController)
            default:
                break
            }
        }
        
        // Other page
        var tableStyle: UITableView.Style = .grouped
        
        if #available(iOS 13.0, *) {
            tableStyle = .insetGrouped
        }
        
        let otherViewController = OtherLinksTableViewController(style: tableStyle)
        let otherNavigationController = UINavigationController(rootViewController: otherViewController)
        
        let otherIcon = UITabBarItem(tabBarSystemItem: .more, tag: self.otherTabIndex)
        otherNavigationController.tabBarItem = otherIcon
        
        controllers.append(otherNavigationController)
        
        // Add controllers
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
