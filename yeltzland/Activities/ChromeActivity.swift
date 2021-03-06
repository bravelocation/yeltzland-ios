//
//  ChromeActivity.swift
//  yeltzland
//
//  Created by John Pollard on 14/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit

class ChromeActivity: UIActivity {
    
    var currentUrl: URL?

    init(currentUrl: URL?) {
        self.currentUrl = currentUrl
        super.init()
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.bravelocation.yeltzland.chrome")
    }
    
    override var activityImage: UIImage {
        return UIImage(named: "chrome")!
    }
    
    override var activityTitle: String {
        return "Open in Chrome"
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // nothing to prepare
    }
    
    override class var activityCategory: UIActivity.Category {
        return UIActivity.Category.action
    }
    
    func canOpenChrome() -> Bool {
        let chromeUrl = self.generateChromeUrl()
        if (chromeUrl == nil) {
            return false
        }
        
        return UIApplication.shared.canOpenURL(chromeUrl!)
    }
    
    func generateChromeUrl() -> URL! {
        let incomingScheme = self.currentUrl!.scheme
        var chromeScheme = ""
        
        if (incomingScheme == "http") {
            chromeScheme = "googlechrome"
        } else if (incomingScheme == "https") {
            chromeScheme = "googlechromes"
        }
        
        if (chromeScheme != "") {
            let chromeUrl = self.currentUrl!.absoluteString.replacingOccurrences(of: self.currentUrl!.scheme! + "://", with: chromeScheme + "://")
            print("Chrome URL is \(chromeUrl)")
            return URL(string: chromeUrl)!
        }
        
        return nil
    }
    
    override func perform() {
        print("Perform activity")
        
        if let chromeUrl = self.generateChromeUrl() {
            if UIApplication.shared.canOpenURL(chromeUrl) {
                UIApplication.shared.open(chromeUrl, options: [:], completionHandler: nil)
            }
        }
    }
}
