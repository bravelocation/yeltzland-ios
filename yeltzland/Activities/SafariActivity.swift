//
//  SafariActivity.swift
//  yeltzland
//
//  Created by John Pollard on 14/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit

class SafariActivity: UIActivity {
    
    var currentUrl: URL?
    
    init(currentUrl: URL?) {
        self.currentUrl = currentUrl
        super.init()
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.bravelocation.yeltzland.safari")
    }
    
    override var activityImage: UIImage {
        return AppImages.safari!
    }
    
    override var activityTitle: String {
        return "Open in Safari"
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
        if self.currentUrl == nil {
            return false
        }
        
        return UIApplication.shared.canOpenURL(self.currentUrl!)
    }
    
    override func perform() {
        print("Perform activity")
        
        if let currentUrl = self.currentUrl {
            if UIApplication.shared.canOpenURL(currentUrl) {
                UIApplication.shared.open(currentUrl, options: [:], completionHandler: nil)
            }
        }
    }
}
