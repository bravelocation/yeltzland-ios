//
//  NavigationActivity.swift
//  Yeltzland
//
//  Created by John Pollard on 08/11/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

public struct NavigationActivity: Hashable {
    init(main: Bool, navElementId: String, url: URL? = nil) {
        self.main = main
        self.navElementId = navElementId
        self.url = url
    }
    
    init(userInfo: [AnyHashable: Any]) {
        if let navType = userInfo["navType"] as? String {
            self.main = navType == "main"
        } else {
            self.main = false
        }
        
        self.navElementId = userInfo["navElementId"] as? String ?? ""
        
        if let savedUrl = userInfo["url"] as? NSURL {
            self.url = URL(string: savedUrl.path!)
        }
    }
    
    var main: Bool
    var navElementId: String
    var url: URL?
    
    var userInfo: [AnyHashable: Any] {
        get {
            if let url = self.url {
                return [
                    "navType": self.main ? NSString("main") :NSString( "more"),
                    "navElementId": self.navElementId,
                    "url": NSURL(string: url.path)!
                ]
            } else {
                return [
                    "navType": self.main ? NSString("main") :NSString( "more"),
                    "navElementId": self.navElementId
                ]
            }
        }
    }
}
