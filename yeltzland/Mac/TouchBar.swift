//
//  TouchBar.swift
//  Yeltzland
//
//  Created by John Pollard on 02/08/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import UIKit

#if targetEnvironment(macCatalyst)
extension NSTouchBarItem.Identifier {
    static let forum = NSTouchBarItem.Identifier("com.bravelocation.yeltzland.touchbar.forum")
    static let officialSite = NSTouchBarItem.Identifier("com.bravelocation.yeltzland.touchbar.officialSite")
    static let yeltzTV = NSTouchBarItem.Identifier("com.bravelocation.yeltzland.touchbar.yeltzTV")
    static let twitter = NSTouchBarItem.Identifier("com.bravelocation.yeltzland.touchbar.twitter")
    static let more = NSTouchBarItem.Identifier("com.bravelocation.yeltzland.touchbar.more")
}

extension MainTabBarController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        
        touchBar.defaultItemIdentifiers = [
            .forum,
            .officialSite,
            .yeltzTV,
            .twitter,
            .more,
            .flexibleSpace
        ]
        
        return touchBar
    }
    
    //swiftlint:disable:next cyclomatic_complexity
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let touchBarItem: NSTouchBarItem?
        
        switch identifier {
        case .forum:
            guard let image = UIImage(named: "forum") else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainTabBarController.handleForumTouchbar(_:)))
        case .officialSite:
            guard let image = UIImage(named: "official") else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainTabBarController.handleOfficialSiteTouchbar(_:)))
        case .yeltzTV:
            guard let image = UIImage(named: "yeltztv") else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainTabBarController.handleYeltzTVTouchbar))
        case .twitter:
            guard let image = UIImage(named: "twitter") else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainTabBarController.handleTwitterTouchbar(_:)))
        case .more:
            guard let image = UIImage(systemName: "ellipsis") else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainTabBarController.handleMoreTouchbar(_:)))
                
        default:
            touchBarItem = nil
        }
        
        return touchBarItem
    }
    
    @objc
    func handleForumTouchbar(_ sender: Any?) {
        self.selectedIndex = 0
    }
    
    @objc
    func handleOfficialSiteTouchbar(_ sender: Any?) {
        self.selectedIndex = 1
    }
    
    @objc
    func handleYeltzTVTouchbar(_ sender: Any?) {
        self.selectedIndex = 2
    }
    
    @objc
    func handleTwitterTouchbar(_ sender: Any?) {
        self.selectedIndex = 3
    }
    
    @objc
    func handleMoreTouchbar(_ sender: Any?) {
        self.selectedIndex = 4
    }
}

#endif
