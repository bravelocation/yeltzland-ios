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
    private lazy var menuSubscriber: AnyCancellable? = nil
    
    @available(iOS 14.0, *)
    private lazy var sidebarViewController = SidebarViewController()
    
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
        } else {
            super.init(coder: NSCoder())
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSecondaryView() -> UIViewController {
        // TODO(JP): get this from navigation manager
        let webViewController = WebPageViewController()
        webViewController.homeUrl = URL(string: "https://yeltz.co.uk")!
        webViewController.pageTitle = "Yeltz Forum"
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
                    self.sidebarViewController.handleMainShortcut(inputValue)
                } else {
                    self.sidebarViewController.handleOtherShortcut(keyInput)
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
}
