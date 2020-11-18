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
}

extension MainSplitViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        
        touchBar.defaultItemIdentifiers = [
            .forum,
            .officialSite,
            .yeltzTV,
            .twitter,
            .flexibleSpace
        ]
        
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let touchBarItem: NSTouchBarItem?
        let imageTintColor = UIColor.white
        
        switch identifier {
        case .forum:
            guard let image = UIImage(named: "forum")?.sd_tintedImage(with: imageTintColor) else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainSplitViewController.handleForumTouchbar(_:)))
        case .officialSite:
            guard let image = UIImage(named: "official")?.sd_tintedImage(with: imageTintColor) else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainSplitViewController.handleOfficialSiteTouchbar(_:)))
        case .yeltzTV:
            guard let image = UIImage(named: "yeltztv")?.sd_tintedImage(with: imageTintColor) else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainSplitViewController.handleYeltzTVTouchbar))
        case .twitter:
            guard let image = UIImage(named: "twitter")?.sd_tintedImage(with: imageTintColor) else { return nil }
            touchBarItem = NSButtonTouchBarItem(identifier: identifier,
                                                image: image,
                                                target: self,
                                                action: #selector(MainSplitViewController.handleTwitterTouchbar(_:)))
                
        default:
            touchBarItem = nil
        }
        
        return touchBarItem
    }
    
    @objc
    func handleForumTouchbar(_ sender: Any?) {
        if #available(macCatalyst 14.0, *) {
            self.sidebarViewController.handleMainKeyboardCommand(1)
        }
    }
    
    @objc
    func handleOfficialSiteTouchbar(_ sender: Any?) {
        if #available(macCatalyst 14.0, *) {
            self.sidebarViewController.handleMainKeyboardCommand(2)
        }
    }
    
    @objc
    func handleYeltzTVTouchbar(_ sender: Any?) {
        if #available(macCatalyst 14.0, *) {
            self.sidebarViewController.handleMainKeyboardCommand(3)
        }
    }
    
    @objc
    func handleTwitterTouchbar(_ sender: Any?) {
        if #available(macCatalyst 14, *) {
            self.sidebarViewController.handleMainKeyboardCommand(4)
        }
    }
}

#endif
