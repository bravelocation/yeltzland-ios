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

public enum NavigationElementType {
    case controller(UIViewController)
    case link(URL)
    case notificationsSettings
    case siri(INIntent)
    case info
}

public struct NavigationElement {
    var title: String
    var subtitle: String?
    var imageName: String?
    var type: NavigationElementType
}
