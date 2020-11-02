//
//  NavigationElement.swift
//  Yeltzland
//
//  Created by John Pollard on 17/10/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import UIKit
import Intents

public enum NavigationElementType: Hashable {
    case controller(UIViewController)
    case link(URL)
    case siri(INIntent)
    case info
}

public struct NavigationElement: Hashable {
    var title: String
    var subtitle: String?
    var imageName: String?
    var type: NavigationElementType
    var keyboardShortcut: String?
    var shortcutName: String?
    
    static func controller(title: String,
                           imageName: String,
                           controller: UIViewController,
                           keyboardShortcut: String? = nil,
                           shortcutName: String? = nil
    ) -> NavigationElement {
        return NavigationElement(title: title,
                                 subtitle: nil,
                                 imageName: imageName,
                                 type: .controller(controller),
                                 keyboardShortcut: keyboardShortcut,
                                 shortcutName: shortcutName)
    }
    
    static func link(title: String,
                     imageName: String?,
                     url: String,
                     keyboardShortcut: String? = nil,
                     shortcutName: String? = nil
    ) -> NavigationElement {
        return NavigationElement(title: title,
                                 subtitle: nil,
                                 imageName: imageName,
                                 type: .link(URL(string: url)!),
                                 keyboardShortcut: keyboardShortcut,
                                 shortcutName: shortcutName)
    }
    
    static func siri(title: String, intent: INIntent) -> NavigationElement {
        return NavigationElement(title: title,
                                 subtitle: nil,
                                 imageName: "siri",
                                 type: .siri(intent))
    }
    
    static func info(info: String) -> NavigationElement {
        return NavigationElement(title: "",
                                 subtitle: info,
                                 imageName: nil,
                                 type: .info)
    }
    
    public static func == (lhs: NavigationElement, rhs: NavigationElement) -> Bool {
        return lhs.title == rhs.title
    }
}
