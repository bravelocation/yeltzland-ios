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
    case notificationsSettings
    case siri(INIntent)
    case info
}

public struct NavigationElement: Hashable {
    var title: String
    var subtitle: String?
    var imageName: String?
    var type: NavigationElementType
    
    static func controller(title: String, imageName: String, controller: UIViewController) -> NavigationElement {
        return NavigationElement(title: title,
                                 subtitle: nil,
                                 imageName: imageName,
                                 type: .controller(controller))
    }
    
    static func link(title: String, imageName: String?, url: String) -> NavigationElement {
        return NavigationElement(title: title,
                                 subtitle: nil,
                                 imageName: imageName,
                                 type: .link(URL(string: url)!))
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
