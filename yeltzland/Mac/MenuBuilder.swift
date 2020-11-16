//
//  MenuBuilder.swift
//  Yeltzland
//
//  Created by John Pollard on 02/08/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let navigationCommand = Notification.Name("com.bravelocation.yeltzland.menu.navigation")
}

@available(iOS 13.0, *)
extension AppDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        guard builder.system == UIMenuSystem.main else { return }
        
        let forumCommand = UIKeyCommand(title: "Yeltz Forum", action: #selector(forumMenuCalled), input: "1", modifierFlags: .command)
        let officialSiteCommand = UIKeyCommand(title: "Official Site", action: #selector(officialSiteMenuCalled), input: "2", modifierFlags: .command)
        let yeltzTVCommand = UIKeyCommand(title: "Yeltz TV", action: #selector(yeltzTVMenuCalled), input: "3", modifierFlags: .command)
        let twitterCommand = UIKeyCommand(title: "Twitter", action: #selector(twitterMenuCalled), input: "4", modifierFlags: .command)
        
        let pagesMenu = UIMenu(title: "", options: .displayInline, children: [forumCommand, officialSiteCommand, yeltzTVCommand, twitterCommand])
        
        let fixturesCommand = UIKeyCommand(title: "Fixture List", action: #selector(fixturesMenuCalled), input: "F", modifierFlags: .command)
        let latestScoreCommand = UIKeyCommand(title: "Latest Score", action: #selector(latestScoreMenuCalled), input: "L", modifierFlags: .command)
        let groundCommand = UIKeyCommand(title: "Where's the Ground", action: #selector(groundMenuCalled), input: "G", modifierFlags: .command)
        let tableCommand = UIKeyCommand(title: "League Table", action: #selector(tableMenuCalled), input: "T", modifierFlags: .command)
        
        let moreMenu = UIMenu(title: "", options: .displayInline, children: [fixturesCommand, latestScoreCommand, groundCommand, tableCommand])
        
        let navigationMenu = UIMenu(title: "Navigation", children: [pagesMenu, moreMenu])
        builder.insertSibling(navigationMenu, afterMenu: .edit)
    }
    
    @objc
    func forumMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }

    @objc
    func officialSiteMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
    
    @objc
    func yeltzTVMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
    
    @objc
    func twitterMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
    
    @objc
    func moreMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
    
    @objc
    func fixturesMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
    
    @objc
    func latestScoreMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
    
    @objc
    func groundMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
    
    @objc
    func tableMenuCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
}
