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

public struct ActivityInfo: Hashable {
    var title: String
    var invocationPhrase: String
}

public struct NavigationElement: Hashable {
    var title: String
    var subtitle: String?
    var imageName: String?
    var type: NavigationElementType
    var keyboardShortcut: String?
    var shortcutName: String?
    var activityInfo: ActivityInfo?
    
    var id: String {
        get {
            var typeName = "none"
            
            switch self.type {
            case .controller:
                typeName = "controller"
            case .info:
                typeName = "info"
            case .link:
                typeName = "link"
            case .siri:
                typeName = "siri"
            }
            
            return String(format: "%@:%@", self.title.replacingOccurrences(of: " ", with: ".").lowercased(), typeName)
        }
    }
    
    static func controller(title: String,
                           imageName: String,
                           controller: UIViewController,
                           keyboardShortcut: String? = nil,
                           shortcutName: String? = nil,
                           activityInfo: ActivityInfo? = nil
    ) -> NavigationElement {
        return NavigationElement(title: title,
                                 subtitle: nil,
                                 imageName: imageName,
                                 type: .controller(controller),
                                 keyboardShortcut: keyboardShortcut,
                                 shortcutName: shortcutName,
                                 activityInfo: activityInfo)
    }
    
    static func link(title: String,
                     imageName: String?,
                     url: String,
                     keyboardShortcut: String? = nil,
                     shortcutName: String? = nil,
                     activityInfo: ActivityInfo? = nil
    ) -> NavigationElement {
        return NavigationElement(title: title,
                                 subtitle: nil,
                                 imageName: imageName,
                                 type: .link(URL(string: url)!),
                                 keyboardShortcut: keyboardShortcut,
                                 shortcutName: shortcutName,
                                 activityInfo: activityInfo)
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
