//
//  MainTabBarController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Official Site
        let officialViewController = WebPageViewController()
        officialViewController.homeUrl = NSURL(string:"http://www.ht-fc.com")
        officialViewController.pageTitle = "Official Site"
        let officialNavigationController = UINavigationController(rootViewController:officialViewController)
        
        let officialIcon = UITabBarItem(title: "Official Site", image: nil, selectedImage: nil)
        officialNavigationController.tabBarItem = officialIcon
        
        // Forum
        let forumViewController = WebPageViewController()
        forumViewController.homeUrl = NSURL(string:"http://www.yeltz.co.uk/0/")
        forumViewController.pageTitle = "Forum"
        let forumNavigationController = UINavigationController(rootViewController:forumViewController)
        
        let forumIcon = UITabBarItem(title: "Forum", image: nil, selectedImage: nil)
        forumNavigationController.tabBarItem = forumIcon
        
        // Yeltz TV
        let tvViewController = WebPageViewController()
        tvViewController.homeUrl = NSURL(string:"https://www.youtube.com/user/HalesowenTownFC")
        tvViewController.pageTitle = "Yeltz TV"
        let tvNavigationController = UINavigationController(rootViewController:tvViewController)
        
        let tvIcon = UITabBarItem(title: "Yeltz TV", image: nil, selectedImage: nil)
        tvNavigationController.tabBarItem = tvIcon
        
        let controllers = [forumNavigationController, officialNavigationController, tvNavigationController]
        
        self.viewControllers = controllers
    }
    
    // Delegate methods
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title) ?")
        return true;
    }
}