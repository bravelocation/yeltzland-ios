//
//  SettingsManager.swift
//  yeltzland
//
//  Created by John Pollard on 26/09/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import Foundation

public class SettingsManager {
    fileprivate static let sharedInstance = SettingsManager()
    class var shared: SettingsManager {
        get {
            return sharedInstance
        }
    }
    
    private var settings: NSDictionary
    
    init() {
        if let path = Bundle.main.path(forResource: "Settings", ofType: "plist") {
            self.settings = NSDictionary(contentsOfFile: path)!
        } else {
            self.settings = NSDictionary()
        }
    }
    
    public func getSetting(_ key: String) -> Any? {
        return self.settings[key]
    }
}
