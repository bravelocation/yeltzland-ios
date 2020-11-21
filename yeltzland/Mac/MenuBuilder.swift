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
    static let reloadCommand = Notification.Name("com.bravelocation.yeltzland.menu.reload")
    static let historyCommand = Notification.Name("com.bravelocation.yeltzland.menu.history")
}

@available(iOS 13.0, *)
extension AppDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        guard builder.system == UIMenuSystem.main else { return }
        
        // Setup navigation
        let forumCommand = UIKeyCommand(title: "Yeltz Forum", action: #selector(forumMenuCalled), input: "1", modifierFlags: .command)
        let officialSiteCommand = UIKeyCommand(title: "Official Site", action: #selector(officialSiteMenuCalled), input: "2", modifierFlags: .command)
        let yeltzTVCommand = UIKeyCommand(title: "Yeltz TV", action: #selector(yeltzTVMenuCalled), input: "3", modifierFlags: .command)
        let twitterCommand = UIKeyCommand(title: "Twitter", action: #selector(twitterMenuCalled), input: "4", modifierFlags: .command)
        
        let pagesMenu = UIMenu(title: "", options: .displayInline, children: [forumCommand, officialSiteCommand, yeltzTVCommand, twitterCommand])
        
        let fixturesCommand = UIKeyCommand(title: "Fixture List", action: #selector(fixturesMenuCalled), input: "F", modifierFlags: .command)
        let latestScoreCommand = UIKeyCommand(title: "Latest Score", action: #selector(latestScoreMenuCalled), input: "L", modifierFlags: .command)
        let groundCommand = UIKeyCommand(title: "Where's the Ground", action: #selector(groundMenuCalled), input: "G", modifierFlags: .command)
        let tableCommand = UIKeyCommand(title: "League Table", action: #selector(tableMenuCalled), input: "T", modifierFlags: [.shift, .command])
        
        let moreMenu = UIMenu(title: "", options: .displayInline, children: [fixturesCommand, latestScoreCommand, groundCommand, tableCommand])
        
        let navigationMenu = UIMenu(title: "Navigate", children: [pagesMenu, moreMenu])
        builder.insertSibling(navigationMenu, afterMenu: .view)
        
        // Add Reload into view menu
        let reloadCommand = UIKeyCommand(title: "Reload", action: #selector(reloadCalled), input: "R", modifierFlags: .command)
        let reloadMenu = UIMenu(title: "", options: .displayInline, children: [reloadCommand])
        builder.insertChild(reloadMenu, atEndOfMenu: .view)
        
        // Add a History menu
        let backCommand = UIKeyCommand(title: "Back", action: #selector(backCalled), input: "[", modifierFlags: .command)
        let forwardCommand = UIKeyCommand(title: "Forward", action: #selector(forwardCalled), input: "]", modifierFlags: .command)
        let homeCommand = UIKeyCommand(title: "Home", action: #selector(homeCalled), input: "H", modifierFlags: [.command, .shift])
        
        let historyMenu = UIMenu(title: "History", children: [backCommand, forwardCommand, homeCommand])
        builder.insertSibling(historyMenu, afterMenu: .view)
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
    
    @objc
    func reloadCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .reloadCommand, object: sender)
    }
    
    @objc
    func backCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .historyCommand, object: sender)
    }
    
    @objc
    func forwardCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .historyCommand, object: sender)
    }
    
    @objc
    func homeCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .historyCommand, object: sender)
    }
}

extension AppDelegate {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if #available(iOS 13.0, *) {
            switch action {
            case #selector(backCalled):
                if let splitViewController = findMainSplitViewController() {
                    return splitViewController.isBackMenuEnabled()
                }
                
                return false
            case #selector(forwardCalled):
                if let splitViewController = findMainSplitViewController() {
                    return splitViewController.isForwardMenuEnabled()
                }
                
                return false
            case #selector(homeCalled):
                if let splitViewController = findMainSplitViewController() {
                    return splitViewController.isHomeMenuEnabled()
                }
                
                return false
            default:
                break
            }
        }
        
        return true
    }
    
    @available(iOS 13.0, *)
    private func findMainSplitViewController() -> MainSplitViewController? {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as? SceneDelegate {
            return sceneDelegate.window?.rootViewController as? MainSplitViewController
        }
            
        return nil
    }
}
