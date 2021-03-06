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
    
    // Are we running with a split view controller?
    public var usedWithSplitViewController: Bool = false
    
    // MARK: Private variables
    private let defaults = UserDefaults.standard
    private var navigationManager: NavigationManager!
    
    private var otherTabIndex: Int {
        return self.navigationManager.mainSection.elements.count
    }
    
    @available(iOS 13.0, *)
    private lazy var menuSubscriber: AnyCancellable? = nil
    
    // MARK: - Initialisation
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationWatcher()
        self.setupMenuCommandHandler()
    }
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        navigationManager = appDelegate.navigationManager
        
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
        return self.navigationManager.keyCommands(selector: #selector(MainTabBarController.keyboardSelectTab), useMore: true)
    }

    @objc func keyboardSelectTab(sender: UIKeyCommand) {
        if let keyInput = sender.input {
            if let inputValue = Int(keyInput) {
                self.selectedIndex = inputValue - 1
            } else {
                // Set selected tab as More tab
                self.selectedIndex = self.otherTabIndex
                
                // Pass through to other links controller
                if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                    currentController.popToRootViewController(animated: false)
                    if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                        selectedController.handleOtherShortcut(keyInput)
                    }
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
        GameSettings.shared.lastSelectedTab = selectedIndex // Just for legacy iOS 12
        self.setupHandoff()
    }
    
    // MARK: - NSUserActivityDelegate functions
    func userActivityWillSave(_ userActivity: NSUserActivity) {
        if self.usedWithSplitViewController {
            return
        }
        
        DispatchQueue.main.async {
            // If in split view controller and not in compact mode, don't save the activity
            if (self.usedWithSplitViewController && self.traitCollection.horizontalSizeClass != .compact) {
                print("Not saving user activity for tab bar in non-compact mode")
                return
            }
            
            var currentUrl: URL? = nil
            
            // Add current URL if a web view
            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                if let selectedController = currentController.viewControllers[0] as? WebPageViewController {
                    currentUrl = selectedController.webView?.url
                }
            }
            
            if self.selectedIndex == self.otherTabIndex {
                if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                    if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                        if let moreIndexPath = selectedController.selectedIndexPath {
                            if let moreActivity = self.navigationManager.userActivity(for: moreIndexPath,
                                                                               delegate: self,
                                                                               adjustForHeaders: false,
                                                                               moreOnly: true,
                                                                               url: currentUrl) {
                                // Copy activity details
                                userActivity.userInfo = moreActivity.userInfo
                                userActivity.title = moreActivity.title
                                userActivity.suggestedInvocationPhrase = moreActivity.suggestedInvocationPhrase
                                userActivity.isEligibleForHandoff = moreActivity.isEligibleForHandoff
                                userActivity.isEligibleForSearch = moreActivity.isEligibleForSearch
                                userActivity.isEligibleForPrediction = moreActivity.isEligibleForPrediction
                                userActivity.persistentIdentifier = moreActivity.persistentIdentifier
                                userActivity.needsSave = moreActivity.needsSave
                            }
                        } else {
                            let moreActivity = NavigationActivity(main: false,
                                                                  navElementId: self.navigationManager.moreSections[0].elements[0].id, // TODO: Get this from the more controller
                                                                url: currentUrl)
                            userActivity.userInfo = moreActivity.userInfo
                        }
                    }
                }
            } else {
                let activity = NavigationActivity(main: true,
                                              navElementId: self.navigationManager.mainSection.elements[self.selectedIndex].id,
                                              url: currentUrl)
                userActivity.userInfo = activity.userInfo
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
        
        if let userActivity = self.navigationManager.convertLegacyActivity(activity) {
            let navigationActivity = NavigationActivity(userInfo: userActivity.userInfo!)
            self.handleUserActivityNavigation(navigationActivity: navigationActivity)
        }
    }
    
    // MARK: - Private functions
    
    func handleUserActivityNavigation(navigationActivity: NavigationActivity?) {
        if let navActivity = navigationActivity {
            if navActivity.main {
                var tabIndex = 0
                
                for mainElement in self.navigationManager.mainSection.elements {
                    if mainElement.id == navActivity.navElementId {
                        self.selectedIndex = tabIndex
                        
                        if let restoreUrl = navActivity.url {
                            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                                if let selectedController = currentController.viewControllers[0] as? WebPageViewController {
                                    selectedController.loadPage(restoreUrl as URL)
                                    print("Restoring URL to be \(restoreUrl)")
                                }
                            }
                        }
                        
                        return
                    }
                    
                    tabIndex += 1
                }
            } else if navActivity.navElementId.count > 0 {
                // Go to the more tab, and load the element
                self.selectedIndex = self.otherTabIndex
                
                if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                    currentController.popToRootViewController(animated: false)
                    if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                        selectedController.handleUserActivityNavigation(navigationActivity: navigationActivity)
                    }
                }
            } else {
                self.selectedIndex = GameSettings.shared.lastSelectedTab
            }
        }
    }

    /// Sets up the child controllers for the tabs
    func addChildViewControllers() {
        var controllers: [UINavigationController] = []
        
        for mainNavElement in self.navigationManager.mainSection.elements {
            switch mainNavElement.type {
            case .controller(let viewController):
                let navController = UINavigationController(rootViewController: viewController)
                
                let tabIcon = UITabBarItem(title: mainNavElement.title, image: UIImage(named: mainNavElement.imageName!), selectedImage: nil)
                navController.tabBarItem = tabIcon
                
                controllers.append(navController)
            case .link:
                let webViewController = WebPageViewController()
                webViewController.navigationElement = mainNavElement

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
        
        if self.usedWithSplitViewController {
            return
        }
        
        var indexPath = IndexPath(row: self.selectedIndex, section: 0)
        var useMoreOnly = false
        
        if self.selectedIndex == self.otherTabIndex {
            useMoreOnly = true
            
            if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
                if let selectedController = currentController.viewControllers[0] as? OtherLinksTableViewController {
                    if let selectedIndex = selectedController.selectedIndexPath {
                        indexPath = selectedIndex
                    } else {
                        indexPath = IndexPath(row: 0, section: 0)
                    }
                }
            }
        }
        
        var currentUrl: URL? = nil
        
        // Add current URL if a web view
        if let currentController = self.viewControllers![self.selectedIndex] as? UINavigationController {
            if let selectedController = currentController.viewControllers[0] as? WebPageViewController {
                currentUrl = selectedController.webView?.url
            }
        }
        
        let activity = self.navigationManager.userActivity(for: indexPath,
                                                           delegate: self,
                                                           adjustForHeaders: false,
                                                           moreOnly: useMoreOnly,
                                                           url: currentUrl)

        self.userActivity = activity
        self.userActivity?.becomeCurrent()
        
        if self.selectedIndex != self.otherTabIndex {
            self.navigationManager.lastUserActivity = activity
        }
        
        if #available(iOS 13.0, *) {
            self.view.window?.windowScene?.userActivity = activity
        }
    }
}
