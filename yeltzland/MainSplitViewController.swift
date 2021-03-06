//
//  MainSplitViewController.swift
//  Yeltzland
//
//  Created by John Pollard on 01/11/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import UIKit

#if canImport(SwiftUI)
import Combine
#endif

class MainSplitViewController: UISplitViewController {
    
    @available(iOS 13.0, *)
    private lazy var navigationCommandSubscriber: AnyCancellable? = nil
    
    @available(iOS 13.0, *)
    private lazy var reloadCommandSubscriber: AnyCancellable? = nil
    
    @available(iOS 13.0, *)
    private lazy var historyCommandSubscriber: AnyCancellable? = nil
    
    @available(iOS 14.0, *)
    lazy var sidebarViewController = SidebarViewController()
    
    init?(tabController: MainTabBarController) {
        if #available(iOS 14.0, *) {
            super.init(style: .doubleColumn)
            
            self.primaryBackgroundStyle = .sidebar
            self.preferredDisplayMode = .oneOverSecondary
            
            self.setViewController(self.sidebarViewController, for: .primary)
            
            let initalView = self.initialSecondaryView()
            self.setViewController(initalView, for: .secondary)
            
            self.setViewController(tabController, for: .compact)
            
            // Set color of expand button and expanders
            self.view.tintColor = UIColor.white
            
            self.setupMenuCommandHandler()
        } else {
            super.init(coder: NSCoder())
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSecondaryView() -> UIViewController {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigationManager = appDelegate.navigationManager
        
        let webViewController = WebPageViewController()
        webViewController.navigationElement = navigationManager.mainSection.elements.first
        
        return UINavigationController(rootViewController: webViewController)
    }
}

// MARK: - Keyboard options
extension MainSplitViewController {
    override var keyCommands: [UIKeyCommand]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigationManager = appDelegate.navigationManager
        
        return navigationManager.keyCommands(selector: #selector(MainSplitViewController.keyboardSelectTab), useMore: true)
    }

    @objc func keyboardSelectTab(sender: UIKeyCommand) {
        if #available(iOS 14.0, *) {
            if let keyInput = sender.input {
                if let inputValue = Int(keyInput) {
                    self.sidebarViewController.handleMainKeyboardCommand(inputValue)
                } else {
                    self.sidebarViewController.handleOtherKeyboardCommand(keyInput)
                }
            }
        }
    }
}

// MARK: - Menu options
extension MainSplitViewController {
    func setupMenuCommandHandler() {
        if #available(iOS 14.0, *) {
            self.navigationCommandSubscriber = NotificationCenter.default.publisher(for: .navigationCommand)
                .receive(on: RunLoop.main)
                .sink(receiveValue: { notification in
                    if let command = notification.object as? UIKeyCommand {
                        self.keyboardSelectTab(sender: command)
                    }
                })
            
            self.reloadCommandSubscriber = NotificationCenter.default.publisher(for: .reloadCommand)
                .receive(on: RunLoop.main)
                .sink(receiveValue: { _ in
                    print("Handle reload command ...")
                    self.sidebarViewController.handleReloadKeyboardCommand()
                })
            
            self.historyCommandSubscriber = NotificationCenter.default.publisher(for: .historyCommand)
                .receive(on: RunLoop.main)
                .sink(receiveValue: { notification in
                    if let command = notification.object as? UIKeyCommand {
                        self.sidebarViewController.handleHistoryKeyboardCommand(sender: command)
                    }
                })
        }
    }
    
    func isBackMenuEnabled() -> Bool {
        if #available(iOS 14.0, *) {
            if let webViewController = self.sidebarViewController.currentWebController() {
                return webViewController.webView?.canGoBack ?? false
            }
        }
        
        return false
    }
    
    func isForwardMenuEnabled() -> Bool {
        if #available(iOS 14.0, *) {
            if let webViewController = self.sidebarViewController.currentWebController() {
                return webViewController.webView?.canGoForward ?? false
            }
        }
        
        return false
    }
    
    func isHomeMenuEnabled() -> Bool {
        if #available(iOS 14.0, *) {
            return self.sidebarViewController.currentWebController() != nil
        }
        
        return false
    }
}

// MARK: - UIResponder function
extension MainSplitViewController {

    /// Description Restores the tab state based on the juser activity
    /// - Parameter activity: Activity state to restore
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        print("Restoring user activity in split controller ...")
        
        // Pass through directly to sidebar controller
        if #available(iOS 14.0, *) {
            self.sidebarViewController.restoreUserActivity(activity)
        }
    }
}
