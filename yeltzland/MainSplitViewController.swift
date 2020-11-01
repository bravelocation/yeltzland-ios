//
//  MainSplitViewController.swift
//  Yeltzland
//
//  Created by John Pollard on 01/11/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import UIKit

class MainSplitViewController: UISplitViewController {
    
    let tabController: MainTabBarController
    
    init?(tabController: MainTabBarController) {
        self.tabController = tabController

        if #available(iOS 14.0, *) {
            super.init(style: .doubleColumn)
            
            self.primaryBackgroundStyle = .sidebar
            self.preferredDisplayMode = .oneBesideSecondary
            
            let sidebarViewController = SidebarViewController()
            self.setViewController(sidebarViewController, for: .primary)
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
