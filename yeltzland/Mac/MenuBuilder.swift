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
        
        let navigationManager = NavigationManager()
        
        // Add the main page elements
        var pagesCommands: [UIKeyCommand] = []
        var i = 1
        for mainElement in navigationManager.mainSection.elements {
            let command = UIKeyCommand(title: mainElement.title, action: #selector(menuItemCalled), input: "\(i)", modifierFlags: .command)
            pagesCommands.append(command)
            
            i += 1
        }
        
        let pagesMenu = UIMenu(title: "", options: .displayInline, children: pagesCommands)
        
        // Add any other elements
        var moreCommands: [UIKeyCommand] = []
        
        for otherNavSection in navigationManager.moreSections {
            for otherNavElement in otherNavSection.elements {
                if let key = otherNavElement.keyboardShortcut {
                    let command = UIKeyCommand(title: otherNavElement.title, action: #selector(menuItemCalled), input: key, modifierFlags: .command)
                    moreCommands.append(command)
                }
            }
        }
        
        let moreMenu = UIMenu(title: "", options: .displayInline, children: moreCommands)
        
        let navigationMenu = UIMenu(title: "Navigation", children: [pagesMenu, moreMenu])
        builder.insertSibling(navigationMenu, afterMenu: .edit)
    }
   
    @objc
    func menuItemCalled(_ sender: UIKeyCommand) {
        NotificationCenter.default.post(name: .navigationCommand, object: sender)
    }
}
